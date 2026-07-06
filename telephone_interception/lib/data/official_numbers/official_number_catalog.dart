import '../../domain/models/official_number.dart';

/// Public service directory snapshot, verified on 2026-07-06.
///
/// Bank numbers: government-published financial service directory and the
/// official-number list supplied with this project.
/// Carrier numbers: carrier websites and government public service pages.
/// Government numbers: gov.cn and communications-authority hotline lists.
const officialNumberCatalog = <OfficialNumber>[
  OfficialNumber(
    organization: '中国工商银行',
    number: '95588',
    category: OfficialNumberCategory.bank,
    description: '客户服务热线',
  ),
  OfficialNumber(
    organization: '中国工商银行',
    number: '4006695588',
    category: OfficialNumberCategory.bank,
    description: '贵宾服务专线',
  ),
  OfficialNumber(
    organization: '中国建设银行',
    number: '95533',
    category: OfficialNumberCategory.bank,
    description: '客户服务热线',
  ),
  OfficialNumber(
    organization: '中国农业银行',
    number: '95599',
    category: OfficialNumberCategory.bank,
    description: '客户服务热线',
  ),
  OfficialNumber(
    organization: '中国农业银行',
    number: '4006695599',
    category: OfficialNumberCategory.bank,
    description: '信用卡服务热线',
  ),
  OfficialNumber(
    organization: '中国银行',
    number: '95566',
    category: OfficialNumberCategory.bank,
    description: '客户服务热线',
  ),
  OfficialNumber(
    organization: '中国银行',
    number: '4006695566',
    category: OfficialNumberCategory.bank,
    description: '信用卡服务热线',
  ),
  OfficialNumber(
    organization: '交通银行',
    number: '95559',
    category: OfficialNumberCategory.bank,
    description: '客户服务热线',
  ),
  OfficialNumber(
    organization: '交通银行',
    number: '4008009888',
    category: OfficialNumberCategory.bank,
    description: '信用卡服务热线',
  ),
  OfficialNumber(
    organization: '招商银行',
    number: '95555',
    category: OfficialNumberCategory.bank,
    description: '客户服务热线',
  ),
  OfficialNumber(
    organization: '招商银行',
    number: '4008205555',
    category: OfficialNumberCategory.bank,
    description: '信用卡服务热线',
  ),
  OfficialNumber(
    organization: '招商银行',
    number: '4006695555',
    category: OfficialNumberCategory.bank,
    description: '私人银行服务专线',
  ),
  OfficialNumber(
    organization: '中信银行',
    number: '95558',
    category: OfficialNumberCategory.bank,
    description: '客户服务热线',
  ),
  OfficialNumber(
    organization: '上海浦东发展银行',
    number: '95528',
    category: OfficialNumberCategory.bank,
    description: '客户服务热线',
  ),
  OfficialNumber(
    organization: '中国光大银行',
    number: '95595',
    category: OfficialNumberCategory.bank,
    description: '客户服务热线',
  ),
  OfficialNumber(
    organization: '中国民生银行',
    number: '95568',
    category: OfficialNumberCategory.bank,
    description: '客户服务热线',
  ),
  OfficialNumber(
    organization: '中国民生银行',
    number: '4006695568',
    category: OfficialNumberCategory.bank,
    description: '信用卡服务热线',
  ),
  OfficialNumber(
    organization: '中国邮政储蓄银行',
    number: '95580',
    category: OfficialNumberCategory.bank,
    description: '客户服务热线',
  ),
  OfficialNumber(
    organization: '兴业银行',
    number: '95561',
    category: OfficialNumberCategory.bank,
    description: '客户服务热线',
  ),
  OfficialNumber(
    organization: '平安银行',
    number: '95511',
    category: OfficialNumberCategory.bank,
    description: '客户服务热线',
  ),
  OfficialNumber(
    organization: '华夏银行',
    number: '95577',
    category: OfficialNumberCategory.bank,
    description: '客户服务热线',
  ),
  OfficialNumber(
    organization: '广发银行',
    number: '95508',
    category: OfficialNumberCategory.bank,
    description: '客户服务热线',
  ),
  OfficialNumber(
    organization: '北京银行',
    number: '95526',
    category: OfficialNumberCategory.bank,
    description: '客户服务热线',
  ),
  OfficialNumber(
    organization: '中国移动',
    number: '10086',
    category: OfficialNumberCategory.carrier,
    description: '全国客户服务热线',
  ),
  OfficialNumber(
    organization: '中国联通',
    number: '10010',
    category: OfficialNumberCategory.carrier,
    description: '客户服务热线',
  ),
  OfficialNumber(
    organization: '中国电信',
    number: '10000',
    category: OfficialNumberCategory.carrier,
    description: '客户服务热线',
  ),
  OfficialNumber(
    organization: '中国广电',
    number: '10099',
    category: OfficialNumberCategory.carrier,
    description: '全国统一客服热线',
  ),
  OfficialNumber(
    organization: '公安报警',
    number: '110',
    category: OfficialNumberCategory.government,
    description: '刑事、治安案件及紧急求助',
  ),
  OfficialNumber(
    organization: '消防救援',
    number: '119',
    category: OfficialNumberCategory.government,
    description: '火灾及危险事故救援',
  ),
  OfficialNumber(
    organization: '医疗急救',
    number: '120',
    category: OfficialNumberCategory.government,
    description: '急危重症与事故医疗救援',
  ),
  OfficialNumber(
    organization: '交通事故报警',
    number: '122',
    category: OfficialNumberCategory.government,
    description: '道路交通事故报警',
  ),
  OfficialNumber(
    organization: '政务服务便民热线',
    number: '12345',
    category: OfficialNumberCategory.government,
    description: '政务咨询、投诉与便民服务',
  ),
  OfficialNumber(
    organization: '市场监管投诉举报',
    number: '12315',
    category: OfficialNumberCategory.government,
    description: '消费者投诉与市场监管举报',
  ),
  OfficialNumber(
    organization: '人力资源和社会保障',
    number: '12333',
    category: OfficialNumberCategory.government,
    description: '社保、就业和劳动保障咨询',
  ),
  OfficialNumber(
    organization: '公共法律服务',
    number: '12348',
    category: OfficialNumberCategory.government,
    description: '法律咨询与法律援助',
  ),
  OfficialNumber(
    organization: '税务服务热线',
    number: '12366',
    category: OfficialNumberCategory.government,
    description: '纳税缴费咨询服务',
  ),
  OfficialNumber(
    organization: '国家反诈预警劝阻',
    number: '96110',
    category: OfficialNumberCategory.government,
    description: '反诈预警、报案指引与咨询',
  ),
  OfficialNumber(
    organization: '检察服务热线',
    number: '12309',
    category: OfficialNumberCategory.government,
    description: '检察服务与控告申诉',
  ),
  OfficialNumber(
    organization: '法院诉讼服务热线',
    number: '12368',
    category: OfficialNumberCategory.government,
    description: '诉讼服务与案件信息查询',
  ),
  OfficialNumber(
    organization: '国家移民管理局',
    number: '12367',
    category: OfficialNumberCategory.government,
    description: '移民管理政策咨询',
  ),
  OfficialNumber(
    organization: '交通运输服务监督',
    number: '12328',
    category: OfficialNumberCategory.government,
    description: '交通运输服务监督与咨询',
  ),
  OfficialNumber(
    organization: '海关服务热线',
    number: '12360',
    category: OfficialNumberCategory.government,
    description: '海关业务咨询服务',
  ),
  OfficialNumber(
    organization: '海上搜救',
    number: '12395',
    category: OfficialNumberCategory.government,
    description: '水上遇险求救',
  ),
];
