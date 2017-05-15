===============================
GRUBS Reanimated USB Boot Stick
===============================

**GRUBS** is a shell script for transforming removable USB storage into a dual-purpose device that is both a storage medium usable under Linux, Windows, and Mac OS and a GRUB boot device capable of loopback mounting Linux distro ISO files.

Depends: ``grub2``, ``bash``, ``sudo``, ``rsync``

Synopsis
========

.. code-block:: bash

    grubs.sh [ options ] USB_DEVICE_PARTITION

Example: Prepare a USB storage device partition identified as ``/dev/sde1`` ...

.. code-block:: bash

    $ ./grubs.sh sde1

Usage
=====

**0.** Download Linux distro image (ISO) files and place in ``boot/iso``.

**1.** Copy ``boot/grub/grub.cfg.sample`` to ``boot/grub/grub.cfg`` and write entries for the ISO files to be copied to the USB device. To use the sample entries will require separately downloading the matching ISO files. For other ISO files, please note that each Linux distro is a bit different in the manner its booted by GRUB and may require a bit of research. `This post on boot entries for a number of distributions on the Arch Linux Wiki <https://wiki.archlinux.org/index.php/Multiboot_USB_drive#Boot_entries_for_other_distributions>`_ might prove helpful.

**2.** Run program!

**3.** Reboot. Configure the BIOS to accept removable USB storage as boot device. Reboot and GRUB displays a menu of the Linux distros installed on the USB device. Launch and enjoy!

When finished, simply reboot and return to using the USB device as a VFAT-formatted storage medium.

For more details: `Transform a USB stick into a boot device packing multiple Linux distros <http://www.circuidipity.com/multi-boot-usb.html>`_

Happy hacking!

Author
======

| Daniel Wayne Armstrong (aka) VonBrownie
| http://www.circuidipity.com

License
=======

GPLv2. See ``LICENSE`` for more details.
