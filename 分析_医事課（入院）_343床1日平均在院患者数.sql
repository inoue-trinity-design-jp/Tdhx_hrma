/**
 *  医事課 343床1日平均在院患者数
 *
 *  ・入院ＥＦファイルより集計します
 *  ・各月の在院患者数を日数で除算します
 *  ※病棟毎に集計すると、転棟日の数値が二重で計上されます
 *
 *  [20180911]
 *  ・退院日を除外します
 *  ・労災で入院している患者の診療行為の一部がEFファイルに存在しないため、若干の誤差が生じます
 */
select
    sdate as 対象年月
    , ef28 as 病棟コード
    , bto.RYAKUNM as 病棟
    , count(sdate) as 在院患者数
    , round(count(sdate) / date_format(last_day(concat(sdate, '01')), '%e'), 2) as 平均在院患者数
from
    (
        select distinct
            sdate
            , ef02
            , ef24
            , ef28
        from
            /* ★★★年度別のテーブル名 dpc_efn_yyyy を指定します★★★ */ dpc_efn_2018
        where 1=1
            and ef02 not like '9%'
            and ef05 = '90'
            and (ef10 like 'A1%' or ef10 like 'A3%' or ef10 like 'A9%')
            and ef24 != ef03
    ) m
    left outer join ibars_minkb bto
        on  bto.ID = '00182'
        and m.ef28 = bto.INPKBN
        and concat(m.sdate, '01') between bto.YUKOFROMDTE and bto.YUKOENDDTE
group by
    sdate
    , ef28
