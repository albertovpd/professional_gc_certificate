- Notes i found interesting

![alt](pics/elt_tools.png " ")

![alt](pics/etl_pipeline_dataflow.png " ")

![alt](pics/etl_sketch.png " ")

![alt](pics/dataflow_read_from.png " ")

![alt](pics/streaming_data_processing.png " ")

![alt](pics/streaming_pros.png " ")

![alt](pics/pub-sub.png " ")

![alt](pics/pub-sub_pipeline.png " ")

![alt](pics/pub-sub_publish-subscribe.png " ")

![alt](pics/pub-sub_pull-push.png " ")

![alt](pics/cloud_dataflow_windowing.png " ")

![alt](pics/bigtable_uses.png " ")


![alt](pics/bigtable_performance.png " ")

**- BigQuery:**

It is way faster to use a lot of with clauses in the beginning

    WITH name AS (
        SELECT..
    )

than select everything and use a lot of conditions after.

A good example:

        WITH
        rentals_on_day AS (
        SELECT
            rental_id,
            end_date,
            EXTRACT(DATE
            FROM
            end_date) AS rental_date
        FROM
            `bigquery-public-data.london_bicycles.cycle_hire` )
        SELECT
        rental_id,
        rental_date,
        ROW_NUMBER() OVER(PARTITION BY rental_date ORDER BY end_date) AS rental_number_on_day
        FROM
        rentals_on_day
        ORDER BY
        rental_date ASC,
        rental_number_on_day ASC
        LIMIT
        5

Denormalizing:

        WITH
        denormalized_table AS (
        SELECT
            start_station_name,
            end_station_name,
            ST_DISTANCE(ST_GeogPoint(s1.longitude,
                s1.latitude),
            ST_GeogPoint(s2.longitude,
                s2.latitude)) AS distance,
            duration
        FROM
            `bigquery-public-data`.london_bicycles.cycle_hire AS h
        JOIN
            `bigquery-public-data`.london_bicycles.cycle_stations AS s1
        ON
            h.start_station_id = s1.id
        JOIN
            `bigquery-public-data`.london_bicycles.cycle_stations AS s2
        ON
            h.end_station_id = s2.id ),
        durations AS (
        SELECT
            start_station_name,
            end_station_name,
            MIN(distance) AS distance,
            AVG(duration) AS duration,
            COUNT(*) AS num_rides
        FROM
            denormalized_table
        WHERE
            duration > 0
            AND distance > 0
        GROUP BY
            start_station_name,
            end_station_name
        HAVING
            num_rides > 100 )
        SELECT
        start_station_name,
        end_station_name,
        distance,
        duration,
        duration/distance AS pace
        FROM
        durations
        ORDER BY
        pace ASC
        LIMIT
        5

![alt](pics/bigquery_improvements.png " ")