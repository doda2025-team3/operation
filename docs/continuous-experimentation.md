## Experiment Description
In this experiment the color of the submit button was changed, to see whether different color buttons affect the click through rate. For this, the original button background was changed from white to green.

## Falsifiable Hypothesis
**Hypothesis Statement:** Changing the submit button color from White to Green increases the Click-Through Rate (CTR).
**Falsification Criteria:** Falsification Criteria: This hypothesis is considered false if the Green button has a CTR that is equal to or lower than the White button after the testing period.

## Relevant Metrics
We use Prometheus counters to track engagement and calculate the conversion rate.

**Click-Through Rate (CTR):** The ratio of users who click the button to the total number of users for the version who viewed the page.
**Data Sources:** 
* `sms_button_clicks_total`: Total clicks on the submit button.
  * Labels: `version`
* `sms_page_views_total`: Total loads of the SMS form page.
  * Labels: `version`, `device_type`

## Decision Process
Grafana dashboard (**"Continuous Experimentation"**) to visualize these metrics.

**Current Conversion Rate:**
    * **Metric:** Click through rate per version.
    * **Visual:** Shows the % value. "White" is mapped to light-blue, "Green" is mapped to green.
    * **PromQL:** `sum by (version) (rate(sms_button_clicks_total[$__rate_interval])) / sum by (version) (rate(sms_page_views_total[$__rate_interval]))`

A decision is made for the hypothesis through comparing the final values in Current Conversion Rate panel. Where it is a success if `CTR(green) > CTR(white)` and not otherwise with `CTR(green) <= CTR(white)`.

