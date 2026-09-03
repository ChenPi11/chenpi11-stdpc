#!/bin/env python3

"""Automount for LSL."""

import copy
import json
import sys
from dataclasses import dataclass
from pathlib import Path
from shutil import which
from subprocess import run as s_run
from typing import Any, cast

CONFIG_ROOT = "/fs/@"  # Btrfs-root, not / because / is a subvolume.
MOUNT_TABLE_FILE_NAME = ".mount"
MOUNT_CTX_FILE_NAME = ".mount-ctx"

UMOUNT = which("umount") or "umount"
MOUNT = which("mount") or "mount"


def merge_json_dict(target: "dict[str, Any]", src: "dict[str, Any] | None") -> "None":
    """Merge two json-serializable dict.

    Notice it will write to target dict.

    Arguments:
        target (dict[str, Any]): Target dict to merge.
        src (dict[str, Any] | None): Delta to merge.

    """
    if not src:
        return

    for key, val in src.items():
        if key not in target or type(target[key]) != type(val):
            target[key] = val
        elif isinstance(target[key], list):
            target[key].extend(val)
        elif isinstance(target[key], dict):
            merge_json_dict(target[key], val)
        else:
            target[key] = val


def to_mount_command(mnt: "Mount") -> "list[str]":
    """Convert a mount target to mount command."""
    cmd = [MOUNT, str(mnt.dev), str(mnt.target)]
    if mnt.options:
        opt_str = ",".join(
            sorted(
                opt if val is True else f"{opt}={val}"
                for opt, val in mnt.options.items()
                if val is not None
            )
        )
        cmd.extend(["-o", opt_str])

    if mnt.mnt_type == "bind":
        cmd.append("--bind")
    elif mnt.mnt_type == "rbind":
        cmd.append("--rbind")

    return cmd


def parse_mount_table(
    ctx: "dict[str, Any]", target: "Path", *, parent: "Path | None" = None
) -> "list[Mount]":
    """Parse mount table from a directory."""
    if not target.is_absolute():
        print("[ERRI] Internal error: target must be absolute.")
    table_file = target / MOUNT_TABLE_FILE_NAME
    if not table_file.exists():
        return []  # Stop.
    with table_file.open("r", encoding="utf-8") as f:
        try:
            table: list[dict[str, Any]] = json.load(f)
            if not isinstance(cast("Any", table), list):
                raise TypeError("Mount table must be a list of dict.")
        except:
            print(f"[ERRL] Error while loading {table_file.resolve().as_posix()!r}")
            raise

    ctx_file = target / MOUNT_CTX_FILE_NAME
    if ctx_file.exists():  # Optional.
        with ctx_file.open("r", encoding="utf-8") as f:
            try:
                ctx_delta = json.load(f)
                if not isinstance(ctx_delta, dict):
                    raise TypeError("Context must be a dict.")
            except:
                print(f"[ERRL] Error while loading {ctx_file.resolve().as_posix()!r}")
                raise
    else:
        ctx_delta: dict[str, Any] | None = {}

    # Merge context.
    ctx_ = copy.deepcopy(ctx)  # Copy to avoid change input parameter.
    merge_json_dict(ctx_, ctx_delta)
    ctx_["_parent"] = parent or target

    res: list[Mount] = []
    for m in table:
        if not isinstance(cast("Any", m), dict):
            raise TypeError("Mount table must be a list of dict.")
        res.append(Mount.parse(ctx_, {k: v for k, v in m.items()}))

    return res


def is_mount(path: str | Path) -> bool:
    """Check if a path is a mount point."""
    p = Path(path).resolve(strict=False)
    target_str = str(p)

    try:
        with open("/proc/mounts", "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                parts = line.split()
                if len(parts) < 2:
                    continue
                mount_point_raw = parts[1]
                mp = Path(mount_point_raw).resolve(strict=False)
                if str(mp) == target_str:
                    return True
    except FileNotFoundError:
        return Path(path).is_mount()
    return False


def system(cmd: list[str], *, cwd: Path | str | None = None) -> None:
    """Run shell command."""
    print(f"[TRAC] {cmd!r} at {Path(cwd or Path.cwd()).as_posix()!r}")
    ret = s_run(cmd, check=False, cwd=cwd, shell=False).returncode
    if ret != 0:
        raise ValueError(f"Command {cmd!r} return non-zero value {ret}.")


@dataclass
class Mount:
    """Mount target."""

    dev: "str"
    target: "Path"
    mnt_type: "str"
    options: "dict[str, str | bool | None]"
    ctx: "dict[str, Any]"

    @classmethod
    def parse(cls, ctx: "dict[str, Any]", src: "dict[str, Any] | None") -> "Mount":
        """Parse a mount point."""
        src_ = copy.deepcopy(ctx)
        merge_json_dict(src_, src)
        if type(src_["opt"]) not in [dict, type(None)]:
            raise TypeError("Mount options must be null or dict.")
        if src_["opt"] is None:
            src_["opt"] = {}

        return cls(
            dev=str(src_["dev"]),
            target=ctx["_parent"] / Path(str(src_["target"])),
            mnt_type=str(src_.get("type", "")).lower(),
            options=cast("dict[str, str | bool | None]", src_["opt"]),
            ctx=ctx,
        )

    def umount_r(self) -> "None":
        """Umount recursively."""
        system([UMOUNT, "-R", self.target.as_posix()])
        print(f"[UMNT] {self.target.as_posix()}")

    def mount_single(self) -> "None":
        """Mount this mount point."""
        if is_mount(self.target) and "-k" not in sys.argv:
            self.umount_r()
        target = self.ctx["_parent"] / self.target
        if not target.is_absolute():
            print("[ERRI] Internal error: target must be absolute.")
        target.mkdir(parents=True, exist_ok=True)
        # We allow cross-tree mount, like /home/.mount can mount /opt.
        system(to_mount_command(self), cwd=target.parent)
        print(f"[SMNT] {target.as_posix()}")

    def load_sub_mount_points(self) -> "list[Mount]":
        """Load sub mount points in this directory."""
        return parse_mount_table(self.ctx, self.target)

    def mount_r(self) -> "None":
        """Mount recursively."""
        self.mount_single()
        for submnt in self.load_sub_mount_points():
            submnt.mount_r()

if __name__ == "__main__":
    for root_mnt in parse_mount_table({}, Path(CONFIG_ROOT), parent=Path("/")):
        root_mnt.mount_r()
