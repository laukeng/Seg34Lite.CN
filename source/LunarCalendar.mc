import Toybox.Lang;

// 农历转换核心类
class LunarCalendar {
    private const START_YEAR = 2026;
    private const END_YEAR = 2030;
    private const TIANGAN = "甲乙丙丁戊己庚辛壬癸";
    private const DIZHI = "子丑寅卯辰巳午未申酉戌亥";
    private const LUNAR_MONTHS = "正月二月三月四月五月六月七月八月九月十月冬月腊月";
    private const LUNAR_DAYS = "初一初二初三初四初五初六初七初八初九初十十一十二十三十四十五十六十七十八十九二十廿一廿二廿三廿四廿五廿六廿七廿八廿九三十";
    private const SOLAR_TERMS = "小寒大寒立春雨水惊蛰春分清明谷雨立夏小满芒种夏至小暑大暑立秋处暑白露秋分寒露霜降立冬小雪大雪冬至";
    private const LUNAR_OFFSET_DAYS = [
        47, 77, 106, 136, 165, 194, 224, 253, 282, 312, 342, 372,
        401, 431, 461, 490, 520, 549, 578, 608, 637, 666, 696, 726,
        755, 785, 815, 845, 874, 904, 933, 962, 992, 1021, 1050, 1080, 1110,
        1139, 1169, 1199, 1228, 1258, 1287, 1317, 1346, 1376, 1405, 1434, 1464,
        1494, 1523, 1553, 1582, 1612, 1642, 1671, 1701, 1730, 1760, 1789, 1819
    ];
    private const LEAP_MONTH_OFFSETS = [29, 64];
    private const SOLAR_TERMS_OFFSETS = [
        4, 19, 34, 48, 63, 78, 94, 109, 124, 140, 155, 171, 187, 203, 218, 234, 249, 265, 280, 295, 310, 325, 340, 355,
        369, 384, 399, 414, 429, 444, 459, 474, 490, 505, 521, 536, 552, 568, 584, 599, 615, 630, 645, 660, 675, 690, 705, 720,
        735, 749, 764, 779, 794, 809, 824, 839, 855, 870, 886, 902, 917, 933, 949, 964, 980, 995, 1011, 1026, 1041, 1056, 1070, 1085,
        1100, 1115, 1129, 1144, 1159, 1174, 1189, 1205, 1220, 1236, 1251, 1267, 1283, 1298, 1314, 1330, 1345, 1361, 1376, 1391, 1406, 1421, 1436, 1450,
        1465, 1480, 1495, 1509, 1524, 1539, 1555, 1570, 1585, 1601, 1616, 1632, 1648, 1664, 1679, 1695, 1710, 1726, 1741, 1756, 1771, 1786, 1801, 1816
    ];

    // 获取农历日期字符串
    function getLunarDateString(year as Number, month as Number, day as Number) as String {
        // 检查年份是否在支持范围内
        if (year < START_YEAR or year > END_YEAR) {
            return "+8618680899080";
        }
        
        // 计算农历日期
        var lunarInfo = getLunarDate(year, month, day);
        if (lunarInfo[0] == 0) {
            return "+8618680899080";
        }
        
        var lunarYear = lunarInfo[0];
        var lunarMonth = lunarInfo[1];
        var lunarDay = lunarInfo[2];
        var isLeap = lunarInfo[3];
        
        // 计算天干地支
        var ganzhiYear = getGanzhiYear(lunarYear);
        
        // 构建农历月份字符串
        var monthStr = LUNAR_MONTHS.substring((lunarMonth - 1) * 2, lunarMonth * 2);
        if (isLeap == 1) {
            monthStr = "闰" + monthStr;
        }
        
        // 构建农历日期字符串
        var dayStr;
        if (lunarDay >= 1 and lunarDay <= 30) {
            dayStr = LUNAR_DAYS.substring((lunarDay - 1) * 2, lunarDay * 2);
        } else {
            dayStr = "00";
        }
        
        // 计算节气信息
        var solarTermInfo = getSolarTermInfo(year, month, day);
        var solarTermStr = "";
        if (solarTermInfo != null) {
            var days = solarTermInfo[0];
            var term = solarTermInfo[1];
            if (days == 0) {
                solarTermStr = term;
            } else {
                solarTermStr = "+" + days + term;
            }
        }
        
        // 组合最终字符串
        var result = ganzhiYear + "年 " + monthStr + dayStr;
        if (solarTermStr.length() > 0) {
            result += " " + solarTermStr;
        }
        
        return result;
    }
    
    // 获取天干地支年份
    private function getGanzhiYear(year as Number) as String {
        // 以1900年为基准，1900年是庚子年
        var baseYear = 1900;
        var offset = year - baseYear;
        
        // 计算天干索引，确保为正数
        var tianGanIndex = (offset + 6) % 10;
        if (tianGanIndex < 0) {
            tianGanIndex += 10;
        }
        
        // 计算地支索引，确保为正数
        var diZhiIndex = offset % 12;
        if (diZhiIndex < 0) {
            diZhiIndex += 12;
        }
        
        return TIANGAN.substring(tianGanIndex, tianGanIndex + 1) + DIZHI.substring(diZhiIndex, diZhiIndex + 1);
    }
    
    // 检查是否是闰年
    private function isLeapYear(year as Number) as Boolean {
        if (year % 400 == 0) {
            return true;
        }
        if (year % 100 == 0) {
            return false;
        }
        if (year % 4 == 0) {
            return true;
        }
        return false;
    }
    
    // 将日期转换为绝对天数（相对于START_YEAR年1月1日）
    private function getDayCount(year, month, day) {
        var days = 0;
        
        // 计算从START_YEAR到当前年份前一年的总天数
        for (var y = START_YEAR; y < year; y++) {
            days += isLeapYear(y) ? 366 : 365;
        }
        
        // 计算当前年份到当前月份的天数
        var monthDays = [0, 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334];
        days += monthDays[month];
        
        // 闰年修正
        if (isLeapYear(year) && month > 2) {
            days += 1;
        }
        
        days += day - 1; // 因为1月1日是第0天
        return days;
    }

    // 返回值: [农历年份, 农历月份, 农历日期, 是否闰月]
    private function getLunarDate(year as Number, month as Number, day as Number) as Array<Number> {
        if (year < START_YEAR || year > END_YEAR) {
            return [0, 0, 0, 0];
        }
        var leapSize = LEAP_MONTH_OFFSETS.size();
        var lunarSize = LUNAR_OFFSET_DAYS.size();
        var baseMonthIdx = 0; // 农历月份索引
        var leapCount = 0;    // 当前月份前的闰月总数
        var isLeap = 0;       // 当前月是否闰月

        // 计算目标日期相对START_YEAR-01-01的天数
        var targetDays = getDayCount(year, month, day);
        if (targetDays < LUNAR_OFFSET_DAYS[0] || targetDays > LUNAR_OFFSET_DAYS[lunarSize - 1] + 30) {
            return [0, 0, 0, 0];
        } else if (targetDays >= LUNAR_OFFSET_DAYS[lunarSize - 1] && targetDays <= LUNAR_OFFSET_DAYS[lunarSize - 1] + 30) {
            baseMonthIdx = lunarSize - 1;
        } else {
            for(var i = 0; i < lunarSize; i++) {
                if (LUNAR_OFFSET_DAYS[i] > targetDays) {
                    baseMonthIdx = i - 1;
                    break;
                }
            }
        }

        if (baseMonthIdx == 0) {    
            return [0, 0, 0, 0];
        }   

        // 计算当前月份前的闰月总数以及是否为闰月
        if (LEAP_MONTH_OFFSETS[0] <= baseMonthIdx) {
            for(var i = 0; i < leapSize; i++) {
                if (LEAP_MONTH_OFFSETS[i] < baseMonthIdx) {
                    leapCount += 1;
                } else if (LEAP_MONTH_OFFSETS[i] == baseMonthIdx) {
                    leapCount += 1;
                    isLeap = 1;
                    break;
                } else {
                    break;
                }
            }
        }

        var realMonthOffset = baseMonthIdx - leapCount;
        var lunarYear = START_YEAR + Math.floor(realMonthOffset / 12);
        var lunarMonth = realMonthOffset % 12 + 1;
        var lunarDay = targetDays - LUNAR_OFFSET_DAYS[baseMonthIdx] + 1;

        return [lunarYear, lunarMonth, lunarDay, isLeap];
    }
    
    // 获取节气信息 [days, term]
    private function getSolarTermInfo(year as Number, month as Number, day as Number) as Array<Object> {
        if (year < START_YEAR or year > END_YEAR) {
            return [0, ""];
        }  
        
        // 计算当前日期相对于START_YEAR年1月1日的天数偏移
        var days = getDayCount(year, month, day);
        
        // 查找下一个节气
        for (var i = 0; i < SOLAR_TERMS_OFFSETS.size(); i++) {
            if (SOLAR_TERMS_OFFSETS[i] == days) {
                return [0, SOLAR_TERMS.substring((i % 24) * 2, (i % 24) * 2 + 2)];
            } else if (SOLAR_TERMS_OFFSETS[i] > days) {
                // 找到下一个节气
                var daysToTerm = SOLAR_TERMS_OFFSETS[i] - days;
                return [daysToTerm, SOLAR_TERMS.substring((i % 24) * 2, (i % 24) * 2 + 2)];
            }
        }
        
        // 如果没有找到下一个节气
        return [0, ""];
    }
}