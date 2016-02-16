===============================
GRUBS Reanimated USB Boot Stick
===============================

**GRUBS** is a Bash script for transforming a USB stick into a dual-purpose device that is both a storage medium usable under Linux, Windows, and Mac OS and a GRUB boot device packing multiple Linux distros.

See: `Transform a USB stick into a boot device packing multiple Linux distros <http://www.circuidipity.com/multi-boot-usb.html>`_

Requires: ``GRUB2``, ``rsync``

Usage
=====

**0.** Download and copy ``grubs`` script to a location in PATH. Example:

.. code-block:: bash

    $ sudo cp grubs /usr/local/bin

**1.** Create a folder to hold Linux distro images and ``grub.cfg``. Example:

.. code-block:: bash

    $ mkdir -p ~/GRUBS/iso
    $ cp grub.cfg.sample ~/GRUBS/grub.cfg

**2.** Download Linux distro images and place in ``~/GRUBS/iso``.

**3.** Edit sample ``grub.cfg`` with entries for the Linux images to be copied to the device. Each distro is a little bit different in the manner its booted by GRUB.

**4.** Run ``sudo /path/to/grubs [OPTION] DEVICE``. Example: install GRUB and Linux distros to a partition on a USB stick identified as ``/dev/sde1``: 

.. code-block:: console

    $ sudo /usr/local/bin/grubs -i ~/GRUBS/iso -c ~/GRUBS/grub.cfg sde1

See ``grubs -h`` for options.

Reboot, select the USB stick (depends on BIOS) as boot device and GRUB will display a menu of the installed Linux distro images. Reboot again and return to using your USB stick as a regular storage device.

Happy hacking!

Author
======

| Daniel Wayne Armstrong (aka) VonBrownie
| http://www.circuidipity.com

License
=======

GPLv2. See ``LICENSE`` for more details.
