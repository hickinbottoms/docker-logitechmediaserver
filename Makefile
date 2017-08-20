SH=/bin/bash
TAG=$(shell cat lmsdeb.txt | sed -e s/[^_]*_// | sed -e s/_all.deb// | sed -e s/~/-/)
USER=justifiably

build: 
	docker build $(BUILDARGS) --build-arg LMSDEB=`cat lmsdeb.txt` -t $(USER)/logitechmediaserver:$(TAG) .; docker tag $(USER)/logitechmediaserver:$(TAG) $(USER)/logitechmediaserver:latest

update:
	-(LMSLATEST=`wget -O - -q "http://www.mysqueezebox.com/update/?version=7.9.1&revision=1&geturl=1&os=deb"`; if [ "`cat lmsdeb.txt`" = "$$LMSLATEST" ]; then echo "No update available"; exit 1; else /bin/echo -n $$LMSLATEST > lmsdeb.txt; fi)
