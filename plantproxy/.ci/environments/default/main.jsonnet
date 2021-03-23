local services = ['plantproxy'];
local dns_base = 'binarytemple.com';
local infra = import 'infra.libsonnet';
local util = import 'util.libsonnet';

{
  _config+:: {
    name: 'plantproxy',
    // image: std.extVar('image'),
    image: 'eu.gcr.io/cwahackathon/plantproxy:latest',
  },
  deploy: [
    util.namespace('plantproxy'),
    infra.generateDeployment(
      name='plantproxy', namespace='plantproxy', image='eu.gcr.io/cwahackathon/plantproxy:latest', env=[
        { name: 'PLANTUML_SERVER', value: 'plantuml' },
        { name: 'PLANTUML_SERVER_PORT', value: '80' },
      ]
    ),
    infra.generateDeployment(name='plantuml', namespace='plantproxy', image='plantuml/plantuml-server:jetty-v1.2021.1'),
    infra.service('plantproxy', 80, 8081, 'plantproxy'),
    infra.service('plantuml', 80, 8080, 'plantproxy'),
    infra.generateIngress('plantproxy', 'plantproxy', 'plantproxy', dns_base),
    infra.generateCertificate('plantproxy', 'plantproxy', dns_base),
    infra.generateIssuer('plantproxy', 'plantproxy', dns_base),
  ],
}
