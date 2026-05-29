import 'package:latlong2/latlong.dart';

import '../models/category.dart';
import '../models/excursion_route.dart';
import '../models/landmark.dart';

// Данные полностью локальные (без внешних API), координаты — Тюмень и рядом.

const landmarks = <Landmark>[
  Landmark(
    id: 'embankment',
    name: 'Набережная Туры',
    description:
        'Главная прогулочная зона Тюмени с видами на Туру и многоуровневой набережной.',
    history:
        'Тюменская набережная стала одной из самых узнаваемых точек города. '
        'Она формировалась постепенно: от «рабочего» берега к современной городской гостиной '
        'с лестницами, террасами и подсветкой.',
    // OSM (Nominatim): "Набережная" (центральный участок набережной Туры)
    coordinates: LatLng(57.1622105, 65.5227966),
    category: LandmarkCategory.park,
    imageAsset: 'assets/places/embankment_tura.png',
  ),
  Landmark(
    id: 'lovers_bridge',
    name: 'Мост Влюблённых',
    description:
        'Пешеходный мост через Туру — популярное место для встреч и фотосессий.',
    history:
        'Мост связывает берега в историческом центре. Со временем он стал символом романтики: '
        'здесь назначают свидания, гуляют вечером и любуются панорамой города.',
    // OSM (Nominatim): мост Влюблённых
    coordinates: LatLng(57.1641852, 65.5219269),
    category: LandmarkCategory.culture,
    imageAsset: 'assets/places/lovers_bridge.png',
  ),
  Landmark(
    id: 'tsvetnoy_boulevard',
    name: 'Цветной бульвар',
    description:
        'Городской бульвар с фонтанами, аттракционами и уютными аллеями в центре.',
    history:
        'Бульвар стал «пульсом» центра: зимой здесь ставят ёлку, летом проходят фестивали, '
        'а фонтан и скульптуры давно стали точками притяжения.',
    // OSM (Nominatim): Цветной бульвар
    coordinates: LatLng(57.1510900, 65.5366332),
    category: LandmarkCategory.park,
    imageAsset: null,
  ),
  Landmark(
    id: 'slovtsov_museum',
    name: 'Музейный комплекс им. И. Я. Словцова',
    description:
        'Крупный музейный центр с выставками искусства, истории и современными экспозициями.',
    history:
        'Музей развивает традиции тюменского краеведения и выставочной деятельности, '
        'показывая историю региона и культурные проекты разных эпох.',
    // OSM (Nominatim): "Музейный комплекс им. Словцова", Советская 63
    coordinates: LatLng(57.1540095, 65.5499624),
    category: LandmarkCategory.culture,
    imageAsset: 'assets/places/slovtsov_museum.png',
  ),
  Landmark(
    id: 'historic_square',
    name: 'Историческая площадь',
    description:
        'Место, откуда удобно начать знакомство с городом: рядом набережная и ключевые улицы.',
    history:
        'Тюмень часто называют «матерью городов сибирских»: отсюда начиналось освоение Сибири. '
        'Историческая площадь напоминает о первых страницах городской истории.',
    // OSM (Nominatim): Историческая площадь
    coordinates: LatLng(57.1636993, 65.5190195),
    category: LandmarkCategory.culture,
    imageAsset: 'assets/places/historic_square.png',
  ),
  Landmark(
    id: 'holy_trinity_monastery',
    name: 'Свято-Троицкий монастырь',
    description:
        'Один из старейших архитектурных ансамблей Тюмени с тихими дворами и храмами.',
    history:
        'Монастырь хранит следы разных эпох — от деревянных построек к каменным храмам. '
        'Это место, где городская суета становится тише.',
    // OSM (Nominatim): Свято-Троицкий мужской монастырь
    coordinates: LatLng(57.1699254, 65.5129221),
    category: LandmarkCategory.culture,
    imageAsset: 'assets/places/holy_trinity_monastery.png',
  ),
  Landmark(
    id: 'wooden_architecture',
    name: 'Квартал деревянного зодчества',
    description:
        'Улицы со старинными домами и резными наличниками — «деревянное лицо» Тюмени.',
    history:
        'Деревянные дома с ажурной резьбой — визитная карточка сибирских городов. '
        'В Тюмени сохранились целые улицы, где можно увидеть этот стиль вживую.',
    coordinates: LatLng(57.1563, 65.5562),
    category: LandmarkCategory.culture,
    imageAsset: 'assets/places/wooden_architecture.png',
  ),
  Landmark(
    id: 'zatyumensky_park',
    name: 'Затюменский парк',
    description:
        'Большая зелёная зона для прогулок и спорта: дорожки, лесной воздух, пикники.',
    history:
        'Парк — пример того, как город бережно сохраняет природные территории, '
        'давая жителям возможность отдыхать недалеко от центра.',
    // OSM (Nominatim): "Экопарк Затюменский" (точка у входа/остановки)
    coordinates: LatLng(57.1669227, 65.4571723),
    category: LandmarkCategory.park,
    imageAsset: null,
  ),
  Landmark(
    id: 'gagarin_park',
    name: 'Парк им. Гагарина',
    description:
        'Один из популярных парков для семейных прогулок и пробежек.',
    history:
        'Парки в Тюмени активно обновляются: появляются новые маршруты, освещение и площадки. '
        'Гагаринский парк — один из таких «зелёных маршрутов» города.',
    // Источник: справочники/карты (лесопарк им. Ю.А. Гагарина)
    coordinates: LatLng(57.177394, 65.604768),
    category: LandmarkCategory.park,
    imageAsset: null,
  ),
  Landmark(
    id: 'drama_theater',
    name: 'Тюменский драматический театр',
    description:
        'Современное театральное здание и афиша спектаклей на любой вкус.',
    history:
        'Театральная традиция Тюмени — часть культурной жизни города. '
        'Постановки, гастроли и фестивали собирают зрителей круглый год.',
    // OSM (Nominatim): Тюменский драматический театр, ул. Республики 129
    coordinates: LatLng(57.1445287, 65.5598832),
    category: LandmarkCategory.culture,
    imageAsset: 'assets/places/drama_theater.png',
  ),
  Landmark(
    id: 'fine_arts_museum',
    name: 'Музей изобразительных искусств',
    description:
        'Экспозиции живописи и графики, временные выставки и просветительские программы.',
    history:
        'Музейная жизнь Тюмени развивается вместе с городом: сюда приходят за классикой '
        'и за современными проектами.',
    // Источник: справочники (Openarium): ул. Орджоникидзе 47
    coordinates: LatLng(57.15309, 65.54829),
    category: LandmarkCategory.culture,
    imageAsset: 'assets/places/fine_arts_museum.png',
  ),
  Landmark(
    id: 'central_market',
    name: 'Центральный рынок',
    description:
        'Место, где можно почувствовать вкус города: местные продукты и быстрые перекусы.',
    history:
        'Рынки — важная часть городской культуры. Здесь встречаются жители разных районов, '
        'а локальные продукты рассказывают о регионе больше любого путеводителя.',
    // OSM (Nominatim): Центральный рынок
    coordinates: LatLng(57.1479989, 65.5429168),
    category: LandmarkCategory.food,
    imageAsset: null,
  ),
  Landmark(
    id: 'siberian_bistro',
    name: 'Pizza Mia',
    description:
        'Быстрое кафе с пиццей — удобная остановка по маршруту по городу.',
    history:
        'Городские прогулки хорошо сочетаются с короткими гастро‑остановками: '
        'в центре много форматов “быстро и вкусно”, чтобы не выпадать из маршрута.',
    // OSM (Nominatim): Pizza Mia, ул. Республики 94
    coordinates: LatLng(57.1427999, 65.5590794),
    category: LandmarkCategory.food,
    imageAsset: null,
  ),
  Landmark(
    id: 'coffee_old_town',
    name: "Traveler's Coffee",
    description:
        'Кофейня в центре — кофе и десерты, чтобы сделать паузу в прогулке.',
    history:
        'Кофейни — часть современного городского ритма: короткие встречи, работа с ноутбуком '
        'и пауза между достопримечательностями.',
    // OSM (Nominatim): Traveler's Coffee, ул. Республики 46
    coordinates: LatLng(57.1541154, 65.5378124),
    category: LandmarkCategory.food,
    imageAsset: null,
  ),
  Landmark(
    id: 'restaurant_tura_view',
    name: 'Своя компания',
    description:
        'Ресторанный формат для неспешного обеда или ужина после прогулки.',
    history:
        'После маршрута по центру приятно сделать финальную остановку в ресторане — '
        'обсудить впечатления и наметить следующий маршрут.',
    // OSM (Nominatim): "Своя компания" (ресторан), район КПД / ул. Республики
    coordinates: LatLng(57.1349924, 65.5757752),
    category: LandmarkCategory.food,
    imageAsset: null,
  ),
];

const routes = <ExcursionRoute>[
  ExcursionRoute(
    id: 'route_embankment',
    title: 'Прогулка по набережной',
    description:
        'Неспешный маршрут вдоль Туры: набережная, мост и ключевые точки центра.',
    stopIds: [
      'embankment',
      'lovers_bridge',
      'historic_square',
      'fine_arts_museum',
      'tsvetnoy_boulevard',
    ],
    encodedPathPolyline6:
        'ium_lBqmj_|BgHuN}HvR{FaLo@sAwBkElJgUvF_NhDgHzCdGfA`Cv[~r@vA~CtCtHcD`Ie]ry@q]hz@eEdKwFqNyY_t@{@uBsCwHjDgJpBaFpHaRpJ{U|H}RtBvEn@vAvNx[sOx]fOz\\_NxZwY}o@~Qta@vFfM~MyZgO{\\rOy]wNy[o@wAuBwEhDmIlJgUvF_NhDgHaEqG{@qAiMoRmGsHmNsP{IwJgDwA}DzJsIdTsAdDaH`QsJxUqFjNwDjJkRle@iIrSdGDrC?xCBrEVnEf@jEdA~@^hCbAbE`C|D~CtDxDlDtEtGjNjDgJpBaFpHaRpJ{U|H}RhDmIlJgUvF_NhDgHaEqG{@qAiMoRmGsHmNsP{IwJgDwAaKgDm@mLaCce@rD_A\\I~Ac@zEqApRgi@oO}CIAuIbW_@pE`AbR_Bb@]HsD~@wB}a@k@wKcA_a@j@iOzAyI`CaHdAyBxF_NrXcp@Tg@fSic@p@xA`D|GlKa@xCMvTtc@pKrQt@jApB`EgSzg@[t@wCvHiDtIgJpTeAjCePva@mSng@_LtXsAdDsDbJ}DzJsIdTsAdDaH`QsJxUqFjNwDjJkRle@iIrSdGDrC?xCBrEVnEf@jEdAhEbBbE`C|D~CtDxDlDtEtGjNjDgJpBaFpHaRpJ{U|H}RhDmIlJgUvF_NhDgHaEqG{@qAiMoRmGsHmNsP{IwJgDwAaKgDm@mLaCce@rD_A\\I~Ac@aAcR^qEtIcWH@',
  ),
  ExcursionRoute(
    id: 'route_wooden',
    title: 'Деревянное зодчество',
    description:
        'Исторические улицы и резные наличники — атмосферная прогулка по старой Тюмени.',
    stopIds: [
      'wooden_architecture',
      'holy_trinity_monastery',
      'historic_square',
      'fine_arts_museum',
    ],
    encodedPathPolyline6:
        '{lp_lBwif`|B[[}KkMmPoR}BiCcCmC`DaRtAkLZkDd@}EeAsIiAgEiBqCwB_B}Cu@mCCcBLgEtBqDhJ}FlQwKhg@_If^yEhToDfPqEjSsHh^qHd^iMvi@yFx[qA|Oy@tLyCbl@u@fOcEy@_TkFu]wIu@rNq@zMaFraA_@nHa@dJ[nIe@jIqA|T}@vNeB~[mBx]_AlPsB`a@_Cpg@kCdl@SxEgBta@OzEMjDs@t\\o@|TaAvi@IlL[hYJfy@?|CFlLeNnCcpDzo@_dDzi@qJrAG_O]wy@ByIJ}E^qEj@mDzA_HB{MEsYK}Ha@e[mCqv@u@sPAcGwJoDqBeAuAeCgCkIqAgGeA{Mc@u^s@wGsAkFkBkCkB_C_DiA}O{@RqSaRiLeEy@kAhBuB|K_CzUaFtz@gBtReAjKi@dHyAnu@gXoC??fXnCxAou@h@eHdAkKfBuR`Fuz@~B{UtB}KjAiBdEx@`RhLSpS|Oz@~ChAjB~BjBjCrAjFr@vGb@t^dAzMpAfGfCjItAdCpBdAvJnD@bGt@rPlCpv@`@d[J|HDrYCzM{A~Gk@lD_@pEK|ECxI\\vy@F~NHzGxJ{Av\\iEnL_AdR{@``BgHvzDiPv@B~Ah@dC~@fCjB~EnFhCbFtb@xz@|Yxm@~Sxd@zBaGnBwEbL_YdLuX|KcXrJoWdGDrC?xCBrEVnEf@jEdA~@^hCbAbE`C|D~CtDxDlDtEtGjNjDgJpBaFpHaRpJ{U|H}RhDmIlJgUvF_NhDgHaEqG{@qAiMoRmGsHmNsP{IwJgDwAaAcR^qEtIcWH@',
  ),
  ExcursionRoute(
    id: 'route_culture_day',
    title: 'Культура за один день',
    description:
        'Музеи и театр: маршрут для тех, кто любит историю и искусство.',
    stopIds: [
      'slovtsov_museum',
      'fine_arts_museum',
      'drama_theater',
      'historic_square',
    ],
    encodedPathPolyline6:
        '{cj_lBqfo`|BjBjEz@pC\\~A\\`Bn@bCdOza@vB~FbLd[nLp[|CxH`DtIjHjPvKtVzKzVhJ`TzExLbDlHj`@||@vJbT`B~D_Xhp@eKtW}B|FiCvGgCrGyTpj@aBdEci@tpAcCbGiBjE_S~e@o\\fw@g]rx@{ExLsFtMqQtc@wFtOgCrGwAvDgSzg@[t@wCvHiDtIgJpTeAjCePva@mSng@_LtXsAdDsDbJaKgDm@mLaCce@rD_A\\I~Ac@zEqApRgi@oO}CIAuIbW_@pE`AbR_Bb@]HsD~@wB}a@k@wKcA_a@j@iOzAyI`CaHdAyBxF_NrXcp@Tg@fSic@bHgOjZyo@nFuMlFmMnHvNxYnj@xFxKhBhDnDjGrBxDlDdHbTxb@jKfTrEtIjCxE|BdFxAtCd\\fo@~B|EvCvGhBxDhBvD`Qf^x\\zp@jD~GpDjHtDzHrO|ZrMrW~IpPnOjYdDpGhEdIxAzCfJlQbTba@`]dp@hHdNvElJuDdKaNd]gQpc@iDtI}F|N_GbN}FtNm`@|cAeEdKnDzHnI~QbPz]lCbGyKdWoHOeQvb@iJoRo@qAxK`UdQwb@nHNxKeWmCcGcP{]oI_RoD{HqOr_@sDlJgh@~pAaD~Hom@d{A_EpJ}CmHqgAusCiCeGkCqGwE{LkLgZgP}b@aHcQgEoK{CqHyCkHkJgVaAiCgNa^yX{r@wFqNyY_t@{@uBsCwHuGkNmDuEuDyD}D_DcEaCiCcA',
  ),
  ExcursionRoute(
    id: 'route_parks',
    title: 'Зелёная Тюмень',
    description: 'Парки и прогулочные зоны, чтобы отдохнуть и подышать воздухом.',
    stopIds: [
      'zatyumensky_park',
      'tsvetnoy_boulevard',
      'embankment',
      'gagarin_park',
    ],
    encodedPathPolyline6:
        'cv``lB{mh|{B?dAaCDsDDoBBWiw@OcTq@gHnMiRhD_FjDaFtTg[dc@an@pf@_s@n]mf@`]og@RWvEiGtH_Ln`@mj@|BsCn@}Jo@wIqL_h@qJoa@eTu}@sD{OsUa`AqGoW}BoJuCqLcDiMmEmQi@wBud@amBkL{f@sd@_oBsOqk@gBqHeQgo@kZkhAgJg]sOik@qB{HyYchAi]uqAeBqG[iAwByRo@gMX_M~B{PjCsMdC{HzEqNvXuYhToWpSeYlDuGpQuXvn@uhA`HuJ`IyIdK{M~MwIrM}H|LmFz@WlUqHhX}Idh@yP`QwFvDuDxImS|P{`@jL_XtUwj@~EqKdEwJbNu[|CoHrSwe@zDuJrEkKlU{e@lC{GzR}f@tDuIpPa`@xc@{fAfDmIpCwGpFkMlDoIla@}`ApCmGhC{FzNc^hMmZ`Rmc@fCeGvCcH|@uBhQ{a@tO{^jKoV~@{BpAyCnLuXxDcJxVkl@bMqZxDyIhCdGpgAtsC|ClH~DqJ|Mu\\p^o}@dErJfExJ`BvDjAbBhCvAbEzCvEzHnHbRhHzRtMz\\sSd^cIjNyIlOyJzPaFvIqDtGuR_h@kHqRuAwD{Pwd@mDeJ}CmHqgAusCiCeGkCqGwE{LkLgZgP}b@aHcQgEoK{CqHyCkHkJgVaAiCgNa^yX{r@wFqNyY_t@{@uBsCwHjDgJpBaFpHaRpJ{U|H}RhDmIvBjEn@rAzF`L`St`@tHwRqI_QgHuN}HvR{FaLo@sAwBkElJgUvF_NhDgHaEqG{@qAiMoRmGsHmNsP{IwJgDwA}DzJsIdTsAdDaH`QsJxUqFjNwDjJkRle@iIrSwMv@}VaAuCAkC@cQDm`@PkF@w@IsD_@uDiAcEeCoJyGqNkLwFyDeEqAyi@pJeNnCcpDzo@_dDzi@qJrAyG~@kWpCywBjb@{}A`X_R`Dk{@nMeTbEi[|FcPe@iFiBuDkA_E{AuFoBsBs@yLuDyHmCwDiD_EeEaHyGaf@giAyLaZgSag@sD{JsN{]_~Bs_GgEsK{BuFytAsdDiD{I}GiQUi@cDkI}mA{qCkGkMkDkGuYif@snAmvBki@_~@cMqRiEaGsGcOyJgQoJ}OePwWgLeKACACeHoN{F_OqZi~@}Tyt@mLya@qEwOeFoQsDmMk\\kjAiM{c@uGzGsEvKwAjE_Jx^uBtIgYzjAyA~HmR`|@w@dDeBpHcUfaAoPvu@sPtt@yA|GwTfdA}M~n@{^lfBy@jEuAjH}O~|@qQ|eAoAnH_UvrAcEfNqCdDwCrBsb@tLmh@xViUvN}HhCaGxA}Cp@u^`AqC@O~XgApKaKUyIYwIU{IW}IOuJQeIMqAfiC',
  ),
  ExcursionRoute(
    id: 'route_gastro',
    title: 'Гастро-Тюмень',
    description:
        'Вкусный маршрут по центру: рынок, кофе и ужин с видом на реку.',
    stopIds: [
      'central_market',
      'coffee_old_town',
      'siberian_bistro',
      'restaurant_tura_view',
      'embankment',
    ],
    encodedPathPolyline6:
        'i~}~kBkx}~{ByCbHcLxWiCpG_Nv\\sK~Wy@rByDlI{Sdc@mBtDcDcHqi@agAuNaY_GqLgEmIeC_FiMmXmCcGcP{]oI_RoD{HdEeKl`@}cA|FuN~FcN|F}NhDuIfQqc@`Ne]tDeKwEmJiHeNa]ep@cTca@gJmQyA{CiEeIeDqGoOkY_JqPsMsWsO}ZuD{HqDkHkD_Hy\\{p@aQg^iBwDiByDwCwG_C}Ee\\go@yAuC}BeFkCyEsEuIkKgTcTyb@mDeHsByDsFtMqQtc@iBgDs@uAwA}BzLa\\a[ml@uA`D}EcIuQ~c@??tQ_d@_FkJeBeDnFuMlFmMnHvNxYnj@xFxKhBhDnDjGrBxDlDdHbTxb@jKfTrEtIjCxEdGmNtBqFnG{O}CgGmAcCyDwHpEmLlFaNkTsa@hb@{cAcEkHxLaYrCiHcH_O}@{FiBjE_S~e@o\\fw@g]rx@{ExLsFtMqQtc@wFtOgCrGwAvDgSzg@[t@wCvHiDtIgJpTeAjCePva@mSng@zBbGdMrMnPpTzEnGnDjA~ImTpFjKl@lAnB|DnA_DrB~Dl@hApBxDrCrF`E|HuIqPqByDm@iAsB_E~A{Dh[cy@bCqG{BeEo@sA_FuJwEgJoTmc@yFcLg@aAiBmDiDtIgJpTeAjCePva@mSng@_LtXsAdDsDbJ}DzJsIdTsAdDaH`QsJxUqFjNwDjJkRle@iIrSdGDrC?xCBrEVnEf@jEdAhEbBbE`C|D~CtDxDlDtEtGjNjDgJpBaFpHaRpJ{U|H}RhDmIvBjEn@rAzF`L|HwRfHtN',
  ),
];

