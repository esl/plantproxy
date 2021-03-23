{
  generateNginxEPSconfigmap(name, namespace)::
    {
      apiVersion: 'v1',
      data: {
        'default.conf': importstr 'permissive_nginx_cors.conf',
      },
      kind: 'ConfigMap',
      metadata: {
        name: name,
        namespace: namespace,
      },
    },
  generateNginxEPS(name, namespace, claim_name, configmap_name):: {
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
          volumes: [
            {
              name: 'volume',
              persistentVolumeClaim: {
                claimName: claim_name,
              },
            },
            {
              name: 'config-volume',
              configMap: {
                name: configmap_name,
              },
            },
          ],
          containers: [
            {
              name: 'nginx',
              image: 'nginx:1.14.2',
              ports: [
                {
                  containerPort: 80,
                  protocol: 'TCP',
                },
              ],
              resources: {},
              volumeMounts: [
                {
                  name: 'volume',
                  mountPath: '/usr/share/nginx/html',
                },
                {
                  name: 'config-volume',
                  mountPath: '/etc/nginx/conf.d',
                },
              ],
              imagePullPolicy: 'IfNotPresent',
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

  generatePV(name, namespace, server='10.116.85.18')::
    {
      apiVersion: 'v1',
      kind: 'PersistentVolume',
      metadata: {
        name: name,
      },
      spec: {
        capacity: {
          storage: '1T',
        },
        accessModes: ['ReadWriteMany'],
        nfs: {
          path: '/' + namespace,
          server: server,
        },
      },
    },

  generatePVC(claim_name, pv_name, namespace):: {
    kind: 'PersistentVolumeClaim',
    apiVersion: 'v1',
    metadata: {
      name: claim_name,
      namespace: namespace,
    },
    spec: {
      accessModes: [
        'ReadWriteMany',
      ],
      resources: {
        requests: {
          storage: '100G',
        },
      },
      volumeName: pv_name,
      storageClassName: '',
      volumeMode: 'Filesystem',
    },
  },

  service(name, namespace):: {
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
          port: 80,
          targetPort: 80,
        },
      ],
      selector: {
        name: name + '-app',
      },
    },
  },

}
