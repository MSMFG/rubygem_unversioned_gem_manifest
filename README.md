# unversioned_gem_manifest

This gem is aimed at recording any unversioned gem installed into a manifest file within the host filesystem that may be used for triage or collected via a monitoring agent later and is designed for complex continuous delivery pipeline codebases.

Logically it should be installed as early on as possible within your pipelines to analyse remaining gem install activity and is limited in it's dependencies to Ruby standard libraries and gem_pre_unversioned_install (which itself has been crafted to avoid additional dependencies).
## RUBYGEMS_UNVERSIONED_MANIFEST
By default the unversioned gem list will be persisted to /tmm/unversioned_gems.yaml but it is possible to override the name using the environment variable RUBYGEMS_UNVERSIONED_MANIFEST. By results will be serialised in YAML form, however, if a .json extension is provided by setting this variable the results will be serialised in JSON form.

YAML example
```
---
ruby-net-ldap:
- 0.0.4
net-ssh:
- 4.2.0
```

JSON example
```
{"ruby-net-ldap":["0.0.4"],"net-ssh":["4.2.0"]}
```

Also note that versions are stored in an array since it is entirely possible that new gem sources may be added during the provisioning resulting in differing gem revisions arriving.
## RUBYGEMS_UNVERSIONED_MANIFEST_MUTEX
The gem utilises a filesystem based mutex to ensure that overlapping access to the output file does not result in data loss as may be the case if something like puppet is provisioning gems in parallel.

By default a lock file called /tmp/manifest.lock is used to co-ordinate read/write exclusivity, however, it may be useful in some cases to allow that to be overridden and this environment variable can be used to specify an alternate locking file.

One example may be if one has multiple versions of Ruby, such as an embedded Sensu version of Ruby where gems are being installed which differs from the system Ruby. In this case one may conceivably want to provide different locking and manifest locations to provide a better indication of the source of the problem.
