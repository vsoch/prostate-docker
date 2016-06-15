# RAPS

Risk After Prostate Surgery Shiny [Web Application](http://predict.shinyapps.io/raps), Dockerized.

We have developed a tool called RAPS (Risks After Prostate Surgery) that uses a man’s personal characteristics to estimate his probability of: a) prostate cancer recurrence, and b) dying without recurrence within 10 years of radical prostatectomy for his cancer.

# Docker Run Instructions

The application has been dockerized, meaning that it can be deployed locally with Docker. You should first install the [docker engine](https://docs.docker.com/engine/installation/) and [docker-compose](https://docs.docker.com/compose/install/) for your platform, and then clone the repo, and run the application:

      git clone https://github.com/vsoch/prostate-raps
      cd prostate-raps
      docker-compose up -d

If you are interested in the codebase to deploy to [http://shinyapps.io](http://shinyapps.io) please see the [prostate](https://github.com/vsoch/prostate) repo.
