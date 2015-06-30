Run your docker with `docker-compose`. It helps to keep your arguments/settings in a single file and run together in an isolated environment.

Install `docker-compose`
```Python
pip install -U docker-compose
```

To start your application, run following command 
```shell
docker-compose up -d
```

Then open the notebook page
```shell
open http://localhost:8888
```

To stop the service 
```shell
docker-compose stop
```
