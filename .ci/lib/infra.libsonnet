{
  service(name, port, target_port,namespace):: {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      labels: {
        name: name + '-app',
      },
      name: name,
      namespace: namespace,
    },
    spec: {
      ports: [
        {
          name: name + '-app',
          port: port,
          targetPort: target_port,
        },
      ],
      selector: {
        name: name + '-app',
      },
    },
  },

  generateDeployment(name='plantproxy', namespace='plantproxy', image='eu.gcr.io/cwahackathon/plantproxy:latest', env=[]):: {
    kind: 'Deployment',
    apiVersion: 'apps/v1',
    metadata: {
      name: name,
      namespace: namespace,
    },
    spec: {
      replicas: 1,
      selector: {
        matchLabels: {
          name: name + '-app',
        },
      },
      template: {
        metadata: {
          labels: {
            name: name + '-app',
          },
        },
        spec: {
          containers: [
            {
              name: name,
              image: image,
              env: env,
              resources: {},
              imagePullPolicy: 'Always',
            },
          ],
          restartPolicy: 'Always',
          terminationGracePeriodSeconds: 30,
          dnsPolicy: 'ClusterFirst',
          securityContext: {},
          schedulerName: 'default-scheduler',
        },
      },
      strategy: {
        type: 'RollingUpdate',
        rollingUpdate: {
          maxUnavailable: '25%',
          maxSurge: '25%',
        },
      },
      revisionHistoryLimit: 10,
      progressDeadlineSeconds: 600,
    },
  },
  generateFQDN(service, base):: '%(service)s.%(base)s' % { service: service, base: base },
  generateSecretName(service, namespace):: '%(service)s-%(namespace)s-tls-secret' % $ { service: service, namespace: namespace },
  generateIssuerName(service, namespace)::
    '%(service)s-%(namespace)s-letsencrypt-production' % { service: service, namespace: namespace },
  generateCertificateName(service, namespace)::
    '%(service)s-%(namespace)s-certificate' % { service: service, namespace: namespace },
  generateIngress(cname, service, namespace, dns_base):: {
    apiVersion: 'networking.k8s.io/v1',
    kind: 'Ingress',
    metadata: {
      name: cname,
      namespace: namespace,
      annotations: {
        'kubernetes.io/ingress.class': 'nginx',
        'cert-manager.io/issuer': 'plantproxy-plantproxy-letsencrypt-production',
        'nginx.ingress.kubernetes.io/rewrite-target': '/$1',
        'nginx.ingress.kubernetes.io/use-regex': 'true',
      },

    },
    spec: {
      rules: [
        {
          host: $.generateFQDN(cname, dns_base),
          http: {
            paths: [
              {
                backend: {
                  service: {
                    name: service,
                    port: {
                      number: 80,
                    },
                  },
                },

                pathType: 'Prefix'
                ,
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
            name: $.generateSecretName(service, namespace) + "-issuer",
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
