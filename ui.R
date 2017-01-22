#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
        
        # Application title
        titlePanel("Gaussian Process demo"),
        
        # Description
        helpText("The Gaussian Process is a flexible machine learning",
                 "method, with some similarities to the support vector",
                 "machine. In this example the Lake Heuron data is",
                 "fitted with a Gaussian Process consisting of a",
                 "combination of three covariance functions: a pure noise,",
                 "a periodic, and a long-term covariance. You can adjust",
                 "the sliders to set the relative proportion of each",
                 "function to the total data variance and their scale",
                 "parameters. The log-likelihood is displayed below the",
                 "plot."),
        
        # Sidebar with sliders for the parameters
        sidebarLayout(
                sidebarPanel(
                        sliderInput("prop",
                                    "Proportion of noise/periodic/long-term variance (%)",
                                    min = 1,
                                    max = 100,
                                    value = c(10,50)),
                        sliderInput("range_periodic",
                                    "Range of periodic variance (years)",
                                    min = 1,
                                    max = 100,
                                    value = 10),
                        sliderInput("period",
                                    "Period (years)",
                                    min = 1,
                                    max = 20,
                                    value = 10),
                        sliderInput("smooth_periodic",
                                    "Smoothness of periodic variance",
                                    min = 1,
                                    max = 30,
                                    value = 5),
                        sliderInput("range_trend",
                                    "Range of long-term variance (years)",
                                    min = 1,
                                    max = 100,
                                    value = 20)
                ),
                
                # Show a plot of the generated distribution
                mainPanel(
                        plotOutput("GPplot"),
                        h3(textOutput("Likelihood"))
                )
        )
))
