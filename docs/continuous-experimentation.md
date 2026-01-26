## Experiment Description
In this experiment the color of the submit button was changed, to see whether different color buttons affect the average number of clicks the button gets. For this, the original button background was changed from white to green.

## Falsifiable Hypothesis
**Hypothesis Statement:** Changing the submit button color from White to Green increases the average amount of clicks.
**Falsification Criteria:** Falsification Criteria: This hypothesis is considered false if the Green button has an average that is equal to or lower than the White button after the testing period.

## Relevant Metrics
We use Prometheus counters to track clicks and calculate the average rate.

**Avg Clicks Per User (White vs Green)** The average amount of button clicks per page view based on version
**Data Sources:** 
* `sms_button_clicks_total`: Total clicks on the submit button.
  * Labels: `version`
* `sms_page_views_total`: Total loads of the SMS form page.
  * Labels: `version`, `device_type`

## Decision Process
Grafana dashboard (**"Continuous Experimentation"**) to visualize these metrics.

Panel: **Avg Clicks Per User (White vs Green)**
    * **Type:** Stat panel.
    * **Metric:** The average number of button clicks per page view, segmented by version.
    * **Visual:** A box for each version with their button color as background. Within the box there is text with the average amount of button clicks.
    * **PromQL:** `sum by (version) (rate(sms_button_clicks_total[$__rate_interval])) / (sum by (version) (rate(sms_page_views_total[$__rate_interval])) > 0)`

A decision is made for the hypothesis through comparing the final values. Where it is a success if `avg(green) > avg(white)` and not otherwise with `avg(green) <= avg(white)`.

<img width="543" height="250" alt="image" src="https://github.com/user-attachments/assets/44632b2a-7bcd-4be3-91a5-8d49e9103b1a" />


