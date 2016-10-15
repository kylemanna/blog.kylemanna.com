---
title: "Duplicity with GPG Compression"
excerpt: "Random thoughts on using Duplicity to backup data to Dreamhost"
category: linux
tags: [backup, duplicity]
---

## Compressing Duplicity Archives with GPG

Quick benchmark of what each option gets me.

Duplicity home directory with mostly binary files (pdf, images, etc) with default compression:

    $ duplicity --encrypt-key=96907DB4 --sign-key=96907DB4 --include=/home/nitro/svn --exclude=/** --volsize=250 / file:///mnt/backup/duplicity/default

    --------------[ Backup Statistics ]--------------
    StartTime 1276259659.02 (Fri Jun 11 07:34:19 2010)
    EndTime 1276259918.87 (Fri Jun 11 07:38:38 2010)
    ElapsedTime 259.85 (4 minutes 19.85 seconds)
    SourceFiles 34343
    SourceFileSize 1758582413 (1.64 GB)
    NewFiles 34343
    NewFileSize 1758582413 (1.64 GB)
    DeletedFiles 0
    ChangedFiles 0
    ChangedFileSize 0 (0 bytes)
    ChangedDeltaSize 0 (0 bytes)
    DeltaEntries 34343
    RawDeltaSize 1700087247 (1.58 GB)
    TotalDestinationSizeChange 1134113085 (1.06 GB)
    Errors 4
    -------------------------------------------------

Duplicity home directory with mostly binary files (pdf, images, etc) with bzip2:

    $ duplicity --encrypt-key=96907DB4 --sign-key=96907DB4 --include=/home/nitro/svn --exclude=/** --volsize=250 --gpg-options='--compress-algo=bzip2 --bzip2-compress-level=9'  / file:///mnt/backup/duplicity/bz2
    --------------[ Backup Statistics ]--------------
    StartTime 1276258959.45 (Fri Jun 11 07:22:39 2010)
    EndTime 1276259564.09 (Fri Jun 11 07:32:44 2010)
    ElapsedTime 604.64 (10 minutes 4.64 seconds)
    SourceFiles 34343
    SourceFileSize 1758582413 (1.64 GB)
    NewFiles 34343
    NewFileSize 1758582413 (1.64 GB)
    DeletedFiles 0
    ChangedFiles 0
    ChangedFileSize 0 (0 bytes)
    ChangedDeltaSize 0 (0 bytes)
    DeltaEntries 34343
    RawDeltaSize 1700087247 (1.58 GB)
    TotalDestinationSizeChange 1082959785 (1.01 GB)
    Errors 4
    -------------------------------------------------

Duplicity backup of /etc with mostly plain-text files with default compression:

    $ duplicity --encrypt-key=96907DB4 --sign-key=96907DB4 --include=/etc --exclude=/** --volsize=250 / file:///mnt/backup/duplicity/default

    --------------[ Backup Statistics ]--------------
    StartTime 1276260094.21 (Fri Jun 11 07:41:34 2010)
    EndTime 1276260099.76 (Fri Jun 11 07:41:39 2010)
    ElapsedTime 5.55 (5.55 seconds)
    SourceFiles 1393
    SourceFileSize 6574960 (6.27 MB)
    NewFiles 1392
    NewFileSize 6570864 (6.27 MB)
    DeletedFiles 2
    ChangedFiles 0
    ChangedFileSize 0 (0 bytes)
    ChangedDeltaSize 0 (0 bytes)
    DeltaEntries 1394
    RawDeltaSize 5887730 (5.61 MB)
    TotalDestinationSizeChange 968617 (946 KB)
    Errors 31
    -------------------------------------------------

Duplicity backup of /etc with mostly plain-text files with bzip2 compression:

    $ duplicity --encrypt-key=96907DB4 --sign-key=96907DB4 --include=/etc --exclude=/** --volsize=250 --gpg-options='--compress-algo=bzip2 --bzip2-compress-level=9'  / file:///mnt/backup/duplicity/bz2
    --------------[ Backup Statistics ]--------------
    StartTime 1276260124.50 (Fri Jun 11 07:42:04 2010)
    EndTime 1276260127.12 (Fri Jun 11 07:42:07 2010)
    ElapsedTime 2.62 (2.62 seconds)
    SourceFiles 1393
    SourceFileSize 6574960 (6.27 MB)
    NewFiles 1393
    NewFileSize 6574960 (6.27 MB)
    DeletedFiles 0
    ChangedFiles 0
    ChangedFileSize 0 (0 bytes)
    ChangedDeltaSize 0 (0 bytes)
    DeltaEntries 1393
    RawDeltaSize 5887730 (5.61 MB)
    TotalDestinationSizeChange 845953 (826 KB)
    Errors 31
    -------------------------------------------------

In conclusion, it seems that the default options are sufficient in most cases for my backups and the time trade-off isn't worth using bzip2.

