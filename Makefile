.phony: venv roles production ALL

ALL: venv roles
venv: .venv/bin/activate
.venv/bin/activate: requirements.txt
	test -d .venv || virtualenv .venv
	.venv/bin/pip install --upgrade pip virtualenv
	.venv/bin/pip install -Ur requirements.txt
	touch .venv/bin/activate

provisioning/.roles-installed: venv provisioning/requirements.yml
	.venv/bin/ansible-galaxy install --force -r provisioning/requirements.yml -p provisioning/roles/
	touch provisioning/.roles-installed

roles: provisioning/.roles-installed


production: venv roles
	.venv/bin/ansible-playbook -i provisioning/hosts provisioning/playbook.yml

retry: venv roles setup.retry
	.venv/bin/ansible-playbook -i provisioning/hosts provisioning/playbook.yml -l @setup.retry

clean:
	rm -rf .venv setup.retry provisioning/.roles-installed
	git clean -df provisioning/roles
