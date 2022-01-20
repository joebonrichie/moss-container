/*
 * This file is part of moss-container.
 *
 * Copyright © 2020-2022 Serpent OS Developers
 *
 * This software is provided 'as-is', without any express or implied
 * warranty. In no event will the authors be held liable for any damages
 * arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */

module moss.container.context;

import std.concurrency : initOnce;

public import moss.container.fakeroot : FakerootBinary;
import moss.container.fakeroot : discoverFakeroot;

/**
 * Shared singleton instance
 */
private __gshared Context sharedContext = null;

/**
 * Destroy the shared context
 */
static ~this()
{
    if (sharedContext !is null)
    {
        sharedContext.destroy();
        sharedContext = null;
    }
}

/**
 * Return the shared container context
 */
public Context context() @trusted
{
    return initOnce!sharedContext(new Context());
}

/**
 * The Context is shared throughout the codebase as a way
 * of sharing options and providing inspection capability of
 * the target filesystem
 */
public final class Context
{

    /**
     * Update the rootfs directory
     */
    pure @property void rootfs(in string dir) @safe @nogc nothrow
    {
        _rootfs = dir;
    }

    /**
     * Return the rootfs directory
     */
    pure @property const(string) rootfs() @safe @nogc nothrow const
    {
        return _rootfs;
    }

    /**
     * Return location of fakeroot binary
     */
    pure @property FakerootBinary fakerootBinary() @safe @nogc nothrow const
    {
        return _fakeroot;
    }

package:

    /**
     * Called by the Container to inspect the root
     */
    void inspectRoot()
    {
        import std.stdio : writeln;

        writeln("I R INSPECTING THE ROOT: ", rootfs);
        _fakeroot = discoverFakeroot();
        writeln("Fakeroot: ", cast(string) _fakeroot);
    }

private:

    /**
     * Only the context() accessor can create a Context.
     */
    this()
    {

    }

    string _rootfs = null;
    FakerootBinary _fakeroot = FakerootBinary.None;
}
