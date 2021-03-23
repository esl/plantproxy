local services = ['beteps', 'betfront'];
local dns_base = '4781c9f1c6f17815.erlang-solutions.com';
local betinfra = import 'betinfra.libsonnet';
local beteps_nginx = import 'beteps.nginx.libsonnet';
local util = import 'util.libsonnet';
local uof = import 'uof.libsonnet';

{
  _config+:: {
    name: 'betinfra',
    image: std.extVar('image'),
  },
  deploy: [
    [betinfra.generateCertificate(service, service, dns_base) for service in services],
    [betinfra.generateIssuer(service, service, dns_base) for service in services],
    beteps_nginx.generatePV('beteps-fileserver', 'beteps', '10.18.129.210'),
    beteps_nginx.generatePVC('beteps-fileserver-claim', 'beteps-fileserver', 'beteps'),
    beteps_nginx.generateNginxEPSconfigmap('nginx-beteps-configmap', 'beteps'),
    beteps_nginx.generateNginxEPS('nginx-beteps', 'beteps', 'beteps-fileserver-claim', 'nginx-beteps-configmap'),
    beteps_nginx.service('nginx-beteps', 'beteps'),
    betinfra.generateIngress('betfront', 'betfront', 'betfront', dns_base),
    betinfra.generateIngress('beteps', 'nginx-beteps', 'beteps', dns_base),
  ],
  uof: [
    util.namespace('uof'),
    uof.generateUOFconfigmap(
      'uof-configmap',
      'uof',
      {
        "DOTNET_ENVIRONMENT" : 'erlang',
        "KafkaClientID" : '5',
        "KafkaServer" : 'kafka-0.kafka-headless.kafka.svc.cluster.local:9092',
        "NodeID" : '5',
      },
    ),
    uof.generateUOFDeployment('uof', 'uof', 'eu.gcr.io/hollywoodbets/uofproducer:latest', 'uof-configmap'),
  ],
}
