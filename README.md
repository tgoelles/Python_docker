
## Build and tag

* use a tag in the form of x.y.z  (for example 0.1.0)
* use version tag in the form of registry-gitlab.v2c2.at/thomasgoelles/vifscience:x.y.z

```
docker build --rm -f "Dockerfile" -t registry-gitlab.v2c2.at/thomasgoelles/vifscience:x.y.z "."
docker push registry-gitlab.v2c2.at/thomasgoelles/vifscience:x.y.z
```
