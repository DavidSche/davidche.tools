# How to add trusted Root-Certificates

How-to: Adding trusted root certificates to the SO (Win / MAC / Unix).

## How-to list all available ssl CA certificates in Linux.

```bash
# Arch , Debian, Ubuntu
awk -v cmd='openssl x509 -noout -subject' ' /BEGIN/{close(cmd)};{print | cmd}' < /etc/ssl/certs/ca-certificates.crt

# Red-Hat, Fedora, CentOS
awk -v cmd='openssl x509 -noout -subject' ' /BEGIN/{close(cmd)};{print | cmd}' < /etc/ssl/certs/ca-bundle.crt

# Centos 5
awk -v cmd='openssl x509 -noout -subject' ' /BEGIN/{close(cmd)};{print | cmd}' < /etc/pki/tls/certs/ca-bundle.crt
```

---

## Mac OS X

Double click on the certificate is usually enough. It can be done from the console too.

### Add

```bash
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ~/new-root-certificate.crt
```

### Remove

```bash
sudo security delete-certificate -c "<name of existing certificate>"
```

---

## Windows

### Add

```bash
certutil -addstore -f "ROOT" new-root-certificate.crt
```

### Remove

```bash
certutil -delstore "ROOT" serial-number-hex
```

---

## Ubuntu, Debian, Arch

### Add (Option 1)

Copy your CA to dir /usr/local/share/ca-certificates/

```bash
sudo cp foo.crt /usr/local/share/ca-certificates/foo.crt   # Option 1.
sudo cp foo.crt /usr/share/ca-certificates/foo.crt         # Option 2.
```

Update the CA store:

```bash
sudo update-ca-certificates  # Option 1.
trust extract-compat        # Option 2.
```

### Add (Option 2)

Copy your CA to dir /etc/ca-certificates/trust-source/anchors/

```bash
cp foo.crt /etc/ca-certificates/trust-source/anchors/
# Alternative Dir: /usr/share/ca-certificates/trust-source/anchors/
```

Update the CA store:

```bash
update-ca-trust
```

### Remove

Remove your CA (/usr/local/share/ca-certificates/)

```bash
sudo update-ca-certificates --fresh
```

---

## Suse

### Add

Copy your CA to dir /etc/pki/trust/anchors/

```bash
sudo cp foo.crt /etc/pki/trust/anchors/foo.crt
```

Update the CA store:

```bash
sudo update-ca-certificates
```

---

## CentOs > 6.X

### Add

Install the ca-certificates package:

```bash
yum install ca-certificates
```

Enable the dynamic CA configuration feature:

```bash
update-ca-trust force-enable
```

Add it as a new file to /etc/pki/ca-trust/source/anchors/:

```bash
cp foo.crt /etc/pki/ca-trust/source/anchors/
update-ca-trust extract
```

---

## CentOs < 5.X

### Add

Append your trusted certificate to file /etc/pki/tls/certs/ca-bundle.crt

```bash
cat foo.crt >> /etc/pki/tls/certs/ca-bundle.crt
```

---

## Solaris

Solaris-specific Solaris keeps the CA certs in "/etc/certs/CA/".
Hashed links to the CA certs are in "/etc/openssl/certs/" for fast lookup and access (usually by OpenSSL). 

By convention, but not required, the filenames in "/etc/certs/CA" is the cert holder's CN with spaces replaced by underscores ("_") and appended with a .pem file name extension. For example, file "/etc/certs/CA/foo.pem" contains the cert for CN "VeriSign Class 4 Public Primary Certification Authority - G3".

### Add

Make or verify the cert is world-readable, if not already.

```bash
chmod a+r foo.pem; ls -l foo.pem
```

Copy the cert to directory "/etc/certs/CA".

```bash
cp -p foo.pem /etc/certs/CA/
```

Install he cert into "/etc/certs/ca-certificates.crt" and add a hashed link in "/etc/openssl/certs/".

```bash
/usr/sbin/svcadm restart /system/ca-certificates
```

### Verify

Verify the CA cert service has restarted (and processed your new CA cert).

```bash
/usr/sbin/svcs /system/ca-certificates
```

If the service hasn't started it could be the cert is corrupt or is a duplicate of an existing CA cert. Look for error messages in files "/var/svc/log/system-ca-certificates:default.log" and "/system/volatile/system-ca-certificates:default.log"

---

## Firefox Browser

Firefox has its own certificate store.

```
Firefox Options -> Advanced -> Certificates
```

---

## JVM / Java Keystore

Java uses the popular "Java KeyStore (JKS)", it does not use the trusted-root-certificates of the operating system.

```bash
keytool -import -alias CERT_ALIAS_NAME -keystore /usr/java/jdkXXXX/jre/lib/security/cacerts -file foo.crt

### Atlassian Frameworks: Jira and Confluence bring their own version of java.
# <INSTALLATION>/confluence/jre/lib/security/cacerts
# <INSTALLATION>/jira/jre/lib/security/cacerts
```

---

## Links of interest​ (Acrobat, Android, etc)
How can I trust CAcert's root certificate?: http://wiki.cacert.org/FAQ/ImportRootCert

