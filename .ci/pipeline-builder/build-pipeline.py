#!/usr/bin/env python3

"""Usage: build-pipeline.py CONFIG [OUTPUT]

Generate concourse pipeline from YAML
Arguments:
  CONFIG     filename of the YAML configuration file to use
  OUTPUT     file to write the generated pipleline to (default pipeline.yml)
Options:
  -h --help
"""

from yaml import load
from jinja2 import Environment, FileSystemLoader
from docopt import docopt

try:
    from yaml import CLoader as Loader
except ImportError:
    from yaml import Loader


class Infrastructure:
    infrastructure_service_name = None
    repo_name = None
    deploy_key_name = None
    project_name = None
    slack_channel = None

    def __init__(self, params):
        for k, v in params.items():
            if hasattr(self, k):
                setattr(self, k, v)

    def __repr__(self):
        return "%s(i=%r, r=%r, d=%r, p=%r, s=%r)" % (
            self.__class__.__name__, self.infrastructure_service_name, self.repo_name,
            self.deploy_key_name, self.project_name, self.slack_channel
        )


class Microservice:
    service_name = None
    repo_name = None
    deploy_key_name = None
    project_type = None
    docker_image_repo = None

    def __init__(self, params):
        for k, v in params.items():
            if hasattr(self, k):
                setattr(self, k, v)

    def __repr__(self):
        return "%s(s=%r, r=%r, d=%r, p=%r, d=%r)" % (
            self.__class__.__name__, self.service_name, self.repo_name,
            self.deploy_key_name, self.project_type, self.docker_image_repo
        )


def main():
    arguments = docopt(__doc__)
    config = arguments['CONFIG']
    if arguments['OUTPUT']:
        out = arguments['OUTPUT']
    else:
        out = 'pipeline.yml'

    services_file = open(config)
    output_file = open(out, "w")
    inf = None
    microservice_set = set()
    data = load(services_file, Loader=Loader)

    for class_type, details in data.items():
        if class_type == "infrastructure":
            inf = Infrastructure(details)
        if class_type == "microservices":
            for microservice in details:
                service = Microservice(microservice)
                microservice_set.add(service)

    file_loader = FileSystemLoader('templates')
    env = Environment(
        loader=file_loader, trim_blocks=True
    )
    template_file = env.get_template("template-file.yml.j2")
    rendered_output = template_file.render(inf=inf, microservice_set=microservice_set)

    print(rendered_output)
    output_file.write(rendered_output)


if __name__ == '__main__':
    main()
