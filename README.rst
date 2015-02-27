===============================
GRUBS Reanimated USB Boot Stick
===============================

**GRUBS** is a Bash script for transforming a USB stick into a dual-purpose device that is both a storage medium usable under Linux, Windows, and Mac OS and a GRUB boot device packing multiple Linux distros.

See: `Transform a USB stick into a boot device packing multiple Linux distros <http://www.circuidipity.com/multi-boot-usb.html>`_

Requires: ``GRUB2``, ``rsync``

Usage
=====

**0.** `Download GRUBS <https://github.com/vonbrownie/grubs/archive/master.zip>`_, unpack, and copy ``grubs-master/grubs`` script to a location in copy. Example:

.. code-block:: bash

    $ sudo cp grubs-master/grubs /usr/local/bin

**1.** Create a folder to hold Linux distro images and ``grub.cfg``. Example:

.. code-block:: bash

    $ mkdir -p ~/GRUBS/iso
    $ cp grubs-master/grub.cfg ~/GRUBS

**2.** Download Linux distro images and place in ``~/GRUBS/iso``.

**3.** Edit sample ``grub.cfg`` with entries for the Linux images to be copied to the device. Each distro is a little bit different in the manner its booted by GRUB.

**4.** Run ``sudo /path/to/grubs [OPTION] DEVICE``. Example: installs GRUB and Linux distros on a USB stick identified as ``/dev/sde1``: 

.. code-block:: console

    $ sudo /usr/local/bin/grubs -i ~/GRUBS/iso -c ~/GRUBS/grub.cfg sde1

See ``grubs -h`` for options.

Reboot, select the USB stick (depends on BIOS) as boot device and GRUB will display a menu of the installed Linux distro images. Reboot again and return to using your USB stick as a regular storage device.

Happy hacking!

Author
======

| Daniel Wayne Armstrong (aka) VonBrownie
| http://www.circuidipity.com
| https://twitter.com/circuidipity

License
=======

GPLv2. See ``LICENSE`` for more details.
