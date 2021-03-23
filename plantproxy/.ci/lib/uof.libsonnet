//   api:
//     image: eu.gcr.io/hollywoodbets/uofproducer
//     environment:
//       DOTNET_ENVIRONMENT: erlang
//       KafkaClientID: 5
//       KafkaServer: broker1:19092
//       NodeID: 5
//     depends_on:
//       - broker1
//     networks:
//       - public
{
  generateUOFconfigmap(name, namespace, data)::
    {
      apiVersion: 'v1',
      data: data,
      kind: 'ConfigMap',
      metadata: {
        name: name,
        namespace: namespace,
      },
    },
  generateUOFDeployment(name='uof', namespace='uof', image='eu.gcr.io/hollywoodbets/uofproducer:latest', configmap_name='uof_configmap'):: {
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
          //   volumes: [
          //     {
          //       name: 'config-volume',
          //       configMap: {
          //         name: configmap_name,
          //       },
          //     },
          //   ],
          containers: [
            {
              name: name,
              image: image,
              envFrom: [
                {
                  configMapRef: {
                    name: configmap_name,
                  },
                },
              ],
              resources: {},
              //   volumeMounts: [
              //     {
              //       name: 'volume',
              //       mountPath: '/usr/share/nginx/html',
              //     },
              //     {
              //       name: 'config-volume',
              //       mountPath: '/etc/nginx/conf.d',
              //     },
              //   ],
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
}
