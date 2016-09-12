test:
	rspec

jenkins: lint
	rspec --format RspecJunitFormatter  --out rspec.xml

lint:
	bundle exec foodcritic -P .
	cookstyle

.PHONY: lint test jenkins
