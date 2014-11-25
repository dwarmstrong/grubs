===============================
GRUBS Reanimated USB Boot Stick
===============================

**GRUBS** is a Bash script for transforming a USB stick into a dual-purpose device that is both a storage medium usable under Linux, Windows, and Mac OS and a GRUB boot device packing multiple Linux distros.

See: `Transform a USB stick into a boot device packing multiple Linux distros <http://www.circuidipity.com/multi-boot-usb.html>`_

Requirements
============

* ``GRUB2``
* ``rsync``

Usage
=====

**Step 0:** Download Linux distro images and place in the ``iso`` folder.

**Step 1:** Edit the USB stick's sample ``grub.cfg`` with entries for the Linux images to be copied to the device. Each distro is a little bit different in the manner its booted by GRUB.

**Step 2:** Open ``grubs`` in a text editor and modify the ``iso_dir`` and ``grub_conf`` variables to match where ``iso`` and ``grub.cfg`` are located on your system. Or indicate a temporary location and config with the ``-i`` and ``-c`` options. See ``grubs -h`` for details.

**Step 3:** Run (as root) ``/path/to/grubs [OPTION] DEVICE``. Example... FOO installs GRUB and Linux distros on a USB stick identified as ``/dev/sdb1``: 

.. code-block:: console

    $ sudo /home/FOO/bin/grubs -i /path/to/linux/iso_images -c /path/to/usb_stick/grub.cfg sdb1

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
