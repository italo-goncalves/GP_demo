#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)
library(datasets)

# Setup
data("LakeHuron")

x=1875:1972
y=as.numeric(LakeHuron)
xpred <- 1875:2015

v <- var(y)
m <- mean(y)

# Covariance functions
cfun_per <- function(x1, x2, rng, per, sm) {
        d <- outer(x1, x2, function(x1, x2) abs(x1-x2))
        exp(-3*d^2/(rng^2) - 3*sin(pi*d/per)^2/sm^2)
}

cfun_lt <- function(x1, x2, rng) {
        d2 <- outer(x1, x2, function(x1, x2) (x1-x2)^2)
        exp(-3*d2/(rng^2))
}

# Gaussian Process prediction
GP_pred <- function(input){
        # Reading values
        rp <- input$range_periodic
        sm <- input$smooth_periodic
        t <- input$period
        rt <- input$range_trend
        p1 <- input$prop[1]/100
        p2 <- (input$prop[2] - input$prop[1])/100
        p3 <- 1 - p1 - p2
        
        # Covariance matrix
        K <- diag(p1*v, length(x), length(x)) + 
                p2*v*cfun_per(x, x, rp, t, sm) + 
                p3*v*cfun_lt(x, x, rt)
        Kpred <- p2*v*cfun_per(xpred, x, rp, t, sm) + 
                p3 *v* cfun_lt(xpred, x, rt)
        
        # Cholesky decomposition
        L <- t(chol(K))
        
        # Prediction
        w <- solve(t(L), solve(L, y-m))
        pred_mu <- Kpred %*% w + m
        pred_var <- v - colSums(solve(L, t(Kpred))^2)
        pred_up <- pred_mu + 2*sqrt(pred_var)
        pred_down <- pred_mu - 2*sqrt(pred_var)
        
        # Log-likelihood
        lik = -0.5 * sum((y-m) * w) - 
                0.5 * sum(log(diag(L))) - 
                0.5 * length(y) * log(2*pi)
        
        return(list(mu = pred_mu, up = pred_up, down = pred_down,
                    lik = lik))
}

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
        
        pred <- reactive({GP_pred(input)})
        
        output$GPplot <- renderPlot({
                
                pred <- pred()
                
                ggplot() + 
                        geom_ribbon(aes(x=xpred, ymax=pred$up, ymin=pred$down),
                                    fill = "gray50") +
                        geom_point(aes(x=x, y=y)) + 
                        geom_line(aes(x=xpred, y=pred$mu), color = "blue") + 
                        labs(x="Year", y="Level (ft)")
                
        })
        
        output$Likelihood <- renderText({
                pred <- pred()
                paste("Log-likelihood:", pred$lik)
        })
        
})
