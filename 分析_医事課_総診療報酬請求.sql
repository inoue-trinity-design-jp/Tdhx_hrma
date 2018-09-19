/**
 *  医事課 総診療報酬請求
 *
 *  ・外来ＥＦファイルおよびＤファイルより集計します
 *
 *  [20180830]
 *  ・診療科をレセプト科区分から診療科区分に変更します
 *  ・科マスタをdpc_mst_sinryoukaに変更します
 *  ・食事を集計対象とします
 *  ・診療報酬を点数から金額に変更します
 *  [20180911]
 *  ・2018年07月の分析先生の値は 40,393,042
 *        外来: 8,029,670(延べ患者数:5,971)
 *  [20180918]
 *  ・医療機関係数を乗ずるロジックを変更
 */
select
    対象年月
    , 入外
    , 診療科コード
    /* , dpt.KANJINM as 診療科 */
    , dpt.ka_name as 診療科
    , 診療報酬
from
    (
        select
            sdate as 対象年月
            , '外来' as 入外
            , ef26 as 診療科コード
            /* , sum(ef18 * ef21 * 10) as 診療報酬 */
            , sum(ef18 * 10) as 診療報酬
        from
            /* ★★★年度別のテーブル名 dpc_efg_yyyy を指定します★★★ */ dpc_efg_2018
        where 1=1
            and ef02 not like '9%'
            and ef05 != 'SY'
            and ef18 != '0'
        group by
            sdate
            , ef26
        union all
        select
            対象年月
            , '入院'
            , 診療科コード
            , sum(truncate(行為点数 * 医療機関係数, 0) * 円点係数) as 診療報酬
        from (
            select
                sdate as 対象年月
                , d02 as 患者番号
                , d20 as 診療科コード
                , d08 as レセ電コード
                , d10 as 行為名称
                , d11 as 行為点数
                , d15 as 行為回数
                , case d14
                    when '0' then 10
                    else 1
                  end as 円点係数
                , case
                    when d30 = 0 then 1
                    else
                        case
                            when d08 like '9%' then d30
                            else 1
                        end
                  end as 医療機関係数
                  
            from
                /* ★★★年度別のテーブル名 dpc_d_yyyy を指定します★★★ */ dpc_d_2018
            where 1=1
                and d02 not like '9%'
                and d11 != '0'
            ) m
        group by
            対象年月
            , 診療科コード
    ) n
    left outer join dpc_mst_sinryouka dpt
        on  診療科コード = dpt.ka_cd
