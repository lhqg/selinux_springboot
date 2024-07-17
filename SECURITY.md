The Springboot SELinux policy module Security Vulnerability Handling Process
=============================================================================

<https://github.com/lhqg/selinux_springboot>

This document attempts to describe the processes through which sensitive
security relevant bugs can be responsibly disclosed to the Springboot SELinux
policy module project and how the project maintainers should handle such
reports.
As all the other Springboot SELinux policy module process documents, this
document should be considered as a guideline, and not as a strong and rigid
set of rules. Persons reporting bugs are warmly encouraged to cooperate to
address and solve the issues in the way they deem most fitted on every
aspects, technical, human, ...

### Reporting Problems

Problems with the SELinux policy module for Springboot application that are
not suitable for immediate public disclosure should be reported via e-mail
to the current maintainers in the list is below.
We typically request at most a 90 day time period to address the issue
before it is made public, but we will make every effort to address
the issue as quickly as possible and shorten the disclosure window.

* Hubert Quarantel-Colombani, hubert+github @ quarantel . name
  * (GPG fingerprint) 1DED 56C1 4795 636E 581E  B60E 7AC0 C909 CDA8 4214
* Laurent Gaillard,
  * (GPG fingerprint) 0627 B961 2C71 83CD 1837  6CDD 9BB4 88C5 918D D06B

### Resolving Sensitive Security Issues

Upon disclosure of a bug, the maintainers should work together to investigate
the problem and decide on a solution. In order to prevent an early disclosure
of the problem, those working on the solution should do so privately and
outside of the traditional SELinux policy module for SPringboot application
development practices. One possible solution to this is to leverage the
GitHub "Security" functionality to create a private development fork that can
be shared among the maintainers, and optionally the reporter. A placeholder
GitHub issue may be created, but details should remain extremely limited
until such time as the problem has been fixed and responsibly disclosed.

Whenever a CVE, or any other tag, has been assigned to the problem, the
GitHub issue title should include the vulnerability tag once the problem has
been disclosed.

### Public Disclosure

Whenever possible, responsible reporting and patching practices should be
followed, including notification to the linux-distros and oss-security mailing
lists (if applicable).

* <https://oss-security.openwall.org/wiki/mailing-lists/distros>
* <https://oss-security.openwall.org/wiki/mailing-lists/oss-security>