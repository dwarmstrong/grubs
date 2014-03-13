===============================
GRUBS Reanimated USB Boot Stick
===============================

**GRUBS** is a Bash script for transforming a USB stick into a dual-purpose device that is both a storage medium usable under Linux, Windows, and Mac OS and a GRUB boot device packing multiple Linux distros.

See: `Transform a USB stick into a boot device packing multiple Linux distros <http://www.circuidipity.com/multi-boot-usb.html>`_

Requirements
============

* ``GRUB2``

Installation
============

Source
------

To install GRUBS from source:

.. code-block:: console

    $ wget -c https://github.com/vonbrownie/name/releases/download/vX.X.X/grubs-X.X.X.tar.gz
    $ tar -xvzf grubs-X.X.X.tar.gz

Usage
=====

**Step 0:** Download Linux distro images and place in the ``iso`` folder.

**Step 1:** Edit the USB stick's sample ``grub.cfg`` with entries for the Linux images to be copied to the device. Each distro is a little bit different in the manner its booted by GRUB.

**Step 2:** Open ``grubs`` in a text editor and modify the variables ``ISODIR`` and ``CONFIG`` to match where ``iso`` and ``grub.cfg`` are located on your system.

**Step 3:** Just run (as root) ``grubs [DEVICE]``. For example ... to install GRUB and Linux distros on a USB stick identified as ``/dev/sdb1``: 

.. code-block:: console

    $ sudo grubs sdb1

Reboot, select the USB stick (depending on BIOS settings) as boot device and GRUB will display a menu of the installed Linux distro images. Reboot again and return to using your USB stick as a regular storage device.

Author
======

| Daniel Wayne Armstrong (aka) VonBrownie
| http://www.circuidipity.com
| https://twitter.com/circuidipity
| daniel@circuidipity.com

License
=======

GPLv2. See ``LICENSE`` for more details.
