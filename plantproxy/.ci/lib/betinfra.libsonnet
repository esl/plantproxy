{
  generateFQDN(service, base):: '%(service)s.%(base)s' % { service: service, base: base },
  generateSecretName(service, namespace):: '%(service)s-%(namespace)s-tls-secret' % $ { service: service, namespace: namespace },
  generateIssuerName(service, namespace)::
    '%(service)s-%(namespace)s-letsencrypt-production' % { service: service, namespace: namespace },
  generateCertificateName(service, namespace)::
    '%(service)s-%(namespace)s-certificate' % { service: service, namespace: namespace },
  generateIngress(cname, service, namespace, dns_base):: {
    apiVersion: 'networking.k8s.io/v1beta1',
    kind: 'Ingress',
    metadata: {
      name: cname,
      namespace: namespace,
    },
    spec: {
      rules: [
        {
          host: $.generateFQDN(cname, dns_base),
          http: {
            paths: [
              {
                backend: {
                  serviceName: '%(service)s' % { service: service },
                  servicePort: 80,
                },
                path: '/',
              },
            ],
          },
        },
      ],
      tls: [
        {
          hosts: [
            $.generateFQDN(cname, dns_base),
          ],
          secretName: $.generateSecretName(cname, namespace),
        },
      ],
    },
  },
  generateCertificate(service, namespace, dns_base)::
    local fqdn = $.generateFQDN(service, dns_base);
    {
      apiVersion: 'cert-manager.io/v1',
      kind: 'Certificate',
      metadata: {
        name: $.generateCertificateName(service, namespace),
        namespace: namespace,
      },
      spec: {
        commonName: fqdn,
        dnsNames: [
          fqdn,
        ],
        secretName: $.generateSecretName(service, namespace),
        issuerRef: {
          kind: 'Issuer',
          name: $.generateIssuerName(service, namespace),
        },
      },
    },

  generateIssuer(service, namespace, dns_base)::
    {
      apiVersion: 'cert-manager.io/v1',
      kind: 'Issuer',
      metadata: {
        name: $.generateIssuerName(service, namespace),
        namespace: namespace,
      },
      spec: {
        acme: {
          server: 'https://acme-v02.api.letsencrypt.org/directory',
          email: 'sysadmin@erlang-solutions.com',
          privateKeySecretRef: {
            name: $.generateSecretName(service, namespace),
          },
          solvers: [
            {
              http01: {
                ingress: {
                  class: 'nginx',
                },
              },
            },
          ],
        },
      },
    },
}