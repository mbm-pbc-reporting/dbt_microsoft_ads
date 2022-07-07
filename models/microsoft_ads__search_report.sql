with report as (

    select *
    from {{ var('search_performance_daily_report') }}

), 

keywords as (

    select *
    from {{ var('keyword_history') }}
    where is_most_recent_record = True
),

ads as (

    select *
    from {{ var('ad_history') }}
    where is_most_recent_record = True

), 

ad_groups as (

    select *
    from {{ var('ad_group_history') }}
    where is_most_recent_record = True

), 

campaigns as (

    select *
    from {{ var('campaign_history') }}
    where is_most_recent_record = True

), 

accounts as (

    select *
    from {{ var('account_history') }}
    where is_most_recent_record = True

), 

joined as (

    select
        report.date_day,
        accounts.account_name,
        accounts.account_id,
        campaigns.campaign_name,
        campaigns.campaign_id,
        ad_groups.ad_group_name,
        ad_groups.ad_group_id,
        ads.ad_name,
        ads.ad_id,
        keywords.keyword_id,
        keywords.keyword_name,
        report.search_query,
        report.device_os,
        report.device_type,
        report.network,
        sum(report.clicks) as clicks,
        sum(report.impressions) as impressions,
        sum(report.spend) as spend

        {% for metric in var('microsoft_ads__search_report_passthrough_metrics',[]) %}
        , sum(report.{{ metric }}) as {{ metric }}
        {% endfor %}
    from report
    left join ads
        on report.ad_id = ads.ad_id
    left join ad_groups
        on report.ad_group_id = ad_groups.ad_group_id
    left join campaigns
        on report.campaign_id = campaigns.campaign_id
    left join accounts
        on report.account_id = accounts.account_id
    left join keywords
        on report.keyword_id = keywords.keyword_id
    {{ dbt_utils.group_by(15) }}

)

select *
from joined