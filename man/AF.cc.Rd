% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/AFcc.R
\name{AF.cc}
\alias{AF.cc}
\title{Attributable fraction for mached and non-matched case-control sampling designs. NOTE! Deprecated function. Use \code{\link[AF]{AFglm}} (for unmatched case-control studies) or \code{\link[AF]{AFclogit}} (for matched case-control studies).}
\usage{
AF.cc(formula, data, exposure, clusterid, matched = FALSE)
}
\arguments{
\item{formula}{an object of class "\code{formula}" (or one that can be coerced to that class): a symbolic description of the model used for confounder adjustment. The exposure and confounders should be specified as independent (right-hand side) variables. The outcome should be specified as dependent (left-hand side) variable. The formula is used to object a logistic regression by \code{\link[stats]{glm}} for non-matched case-control and conditional logistic regression by \code{\link[drgee]{gee}} (in package \code{\link[drgee]{drgee}}) for matched case-control.}

\item{data}{an optional data frame, list or environment (or object coercible by \code{as.data.frame} to a data frame) containing the variables in the model. If not found in \code{data}, the variables are taken from environment (\code{formula}), typically the environment from which the function is called.}

\item{exposure}{the name of the exposure variable as a string. The exposure must be binary (0/1) where unexposed is coded as 0.}

\item{clusterid}{the name of the cluster identifier variable as a string, if data are clustered (e.g. matched).}

\item{matched}{a logical that specifies if the sampling design is matched (TRUE) or non-matched (FALSE) case-control. Default setting is non-matched (\code{matched = FALSE}).}
}
\value{
\item{AF.est}{estimated attributable fraction.}

\item{AF.var}{estimated variance of \code{AF.est}. The variance is obtained by combining the delta methods with the sandwich formula.}

\item{log.or}{a vector of the estimated log odds ratio for every individual. \code{log.or} contains the estimated coefficient for the exposure variable \code{X} for every level of the confounder \code{Z} as specified by the user in the formula. If the model to be estimated is
 \deqn{logit\{Pr(Y=1|X,Z)\} = \alpha+\beta{X}+\gamma{Z}}{logit {Pr(Y=1|X,Z)} = \alpha + \beta X + \gamma Z}
  then \code{log.or} is the estimate of \eqn{\beta}.
  If the model to be estimated is
  \deqn{logit\{Pr(Y=1|X,Z)\}=\alpha+\beta{X}+\gamma{Z}+\psi{XZ}}{logit{Pr(Y=1|X,Z)} = \alpha + \beta X +\gamma Z +\psi XZ}
  then \code{log.odds} is the estimate of
   \eqn{\beta + \psi{Z}}{\beta + \psi Z}.}

\item{object}{the fitted model. Fitted using logistic regression, \code{\link{glm}}, for non-matched case-control and conditional logistic regression, \code{\link[drgee]{gee}}, for matched case-control.}
}
\description{
\code{AF.cc} estimates the model-based adjusted attributable fraction for data from matched and non-matched case-control sampling designs.
}
\details{
\code{Af.cc} estimates the attributable fraction for a binary outcome \code{Y}
under the hypothetical scenario where a binary exposure \code{X} is eliminated from the population.
The estimate is adjusted for confounders \code{Z} by logistic regression for unmatched case-control (\code{\link[stats]{glm}}) and conditional logistic regression for matched case-control (\code{\link[drgee]{gee}}).
The estimation assumes that the outcome is rare so that the risk ratio can be approximated by the odds ratio, for details see Bruzzi et. al.
Let the AF be defined as
\deqn{AF = 1 - \frac{Pr(Y_0=1)}{Pr(Y = 1)}}{AF = 1 - Pr(Y0 = 1) / Pr(Y = 1)}
where \eqn{Pr(Y_0=1)}{Pr(Y0 = 1)} denotes the counterfactual probability of the outcome if
the exposure would have been eliminated from the population. If \code{Z} is sufficient for confounding control then the probability \eqn{Pr(Y_0=1)}{Pr(Y0 = 1)} can be expressed as
\deqn{Pr(Y_0=1)=E_Z\{Pr(Y=1\mid{X}=0,Z)\}.}{Pr(Y0=1) = E_z{Pr(Y = 1 | X = 0, Z)}.}
Using Bayes' theorem this implies that the AF can be expressed as
\deqn{AF = 1-\frac{E_Z\{Pr(Y=1\mid X=0,Z)\}}{Pr(Y=1)}=1-E_Z\{RR^{-X}(Z)\mid{Y = 1}\}}{
AF = 1 - E_z{Pr( Y = 1 | X = 0, Z)} / Pr(Y = 1) = 1 - E_z{RR^{-X} (Z) | Y = 1}}
where \eqn{RR(Z)} is the risk ratio \deqn{\frac{Pr(Y=1\mid{X=1,Z})}{Pr(Y=1\mid{X=0,Z})}.}{Pr(Y = 1 | X = 1,Z)/Pr(Y=1 | X = 0, Z).}
Moreover, the risk ratio can be approximated by the odds ratio if the outcome is rare. Thus,
\deqn{ AF \approx 1 - E_Z\{OR^{-X}(Z)\mid{Y = 1}\}.}{AF is approximately 1 - E_z{OR^{-X}(Z) | Y = 1}.}
The odds ratio is estimated by logistic regression or conditional logistic regression.
If \code{clusterid} is supplied, then a clustered sandwich formula is used in all variance calculations.
}
\examples{
expit <- function(x) 1 / (1 + exp( - x))
NN <- 1000000
n <- 500

# Example 1: non matched case-control
# Simulate a sample from a non matched case-control sampling design
# Make the outcome a rare event by setting the intercept to -6
intercept <- -6
Z <- rnorm(n = NN)
X <- rbinom(n = NN, size = 1, prob = expit(Z))
Y <- rbinom(n = NN, size = 1, prob = expit(intercept + X + Z))
population <- data.frame(Z, X, Y)
Case <- which(population$Y == 1)
Control <- which(population$Y == 0)
# Sample cases and controls from the population
case <- sample(Case, n)
control <- sample(Control, n)
data <- population[c(case, control), ]

# Estimation of the attributable fraction
AF.cc_est <- AF.cc(formula = Y ~ X + Z + X * Z, data = data, exposure = "X")
summary(AF.cc_est)

# Example 2: matched case-control
# Duplicate observations in order to create a matched data sample
# Create an unobserved confounder U common for each pair of individuals
U  <- rnorm(n = NN)
Z1 <- rnorm(n = NN)
Z2 <- rnorm(n = NN)
X1 <- rbinom(n = NN, size = 1, prob = expit(U + Z1))
X2 <- rbinom(n = NN, size = 1, prob = expit(U + Z2))
Y1 <- rbinom(n = NN, size = 1, prob = expit(intercept + U + Z1 + X1))
Y2 <- rbinom(n = NN, size = 1, prob = expit(intercept + U + Z2 + X2))
# Select discordant pairs
discordant <- which(Y1!=Y2)
id <- rep(1:n, 2)
# Sample from discordant pairs
incl <- sample(x = discordant, size = n, replace = TRUE)
data <- data.frame(id = id, Y = c(Y1[incl], Y2[incl]), X = c(X1[incl], X2[incl]),
                   Z = c(Z1[incl], Z2[incl]))

# Estimation of the attributable fraction
AF.cc_match <- AF.cc(formula = Y ~ X + Z + X * Z, data = data,
                         exposure = "X", clusterid = "id", matched = TRUE)
summary(AF.cc_match)
}
\references{
Bruzzi, P., Green, S. B., Byar, D., Brinton, L. A., and Schairer, C. (1985). Estimating the population attributable risk for multiple risk factors using case-control data. \emph{American Journal of Epidemiology} \bold{122}, 904-914.
}
\seealso{
The new and more general version of the function: \code{\link[AF]{AFglm}} for non-matched and \code{\link[AF]{AFclogit}} for matched case-control sampling designs. \code{\link[stats]{glm}} and \code{\link[drgee]{gee}} used for fitting the logistic regression model (for non-matched case-control) and the conditional logistic regression model (for matched case-control).
}
\author{
Elisabeth Dahlqwist, Arvid \enc{Sjölander}{Sjolander}
}
