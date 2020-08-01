# Biometric Tracker

The biometracker app is a web application designed in R Shiny which helps visualize, analyze and forecast weight loss data. Here are some frequently asked questions with answers.

Q1. How often is the data presented here updated?  
Answer: Typically once a week on Sunday. We would like to have an automated data pipeline setup so that the data automatically gets updated every day and the forecasts rerun based on new data, but since there are no APIs available to extract the data from the weighing machine we use, this is a manual activity.

Q2. I would like to extend this application for my own use case, where is the code available for this and is it open source?  
Answer. The code for this application is available here [on github](https://github.com/aarora79/biomettracker.git). The code is open source and is available under the [GPL-3.0 license.](https://github.com/aarora79/biomettracker/blob/master/LICENSE).

Q3. How do you do the weight forecasting?  
Answer. The weight forecasting is done using an open source timeseries forecasting library called [*Prophet*](https://facebook.github.io/prophet/docs/installation.html#r), this is is provided by Facebook AI Research ([FAIR](https://github.com/facebookresearch)). We specifically use the saturating minimum model option in the logistic model provided by Prophet, see [this link](https://facebook.github.io/prophet/docs/saturating_forecasts.html#saturating-minimum).

Q4. This is cool, i would like to reach out to the author, is there a website, email address?  
Answer. Sure, you can reach out to me, Amit Arora at aa1603@georgetown.edu. You can also see my other work at https://ilivethedata.net.