package com.adminplus.service;

import com.adminplus.dto.DictCreateReq;
import com.adminplus.dto.DictUpdateReq;
import com.adminplus.vo.DictItemVO;
import com.adminplus.vo.DictVO;
import com.adminplus.vo.PageResultVO;

import java.util.List;

/**
 * 字典服务接口
 *
 * @author AdminPlus
 * @since 2026-02-06
 */
public interface DictService {

    /**
     * 分页查询字典列表
     */
    PageResultVO<DictVO> getDictList(Integer page, Integer size, String keyword);

    /**
     * 根据ID查询字典
     */
    DictVO getDictById(Long id);

    /**
     * 根据字典类型查询
     */
    DictVO getDictByType(String dictType);

    /**
     * 根据字典类型查询字典项
     */
    List<DictItemVO> getDictItemsByType(String dictType);

    /**
     * 创建字典
     */
    DictVO createDict(DictCreateReq req);

    /**
     * 更新字典
     */
    DictVO updateDict(Long id, DictUpdateReq req);

    /**
     * 删除字典
     */
    void deleteDict(Long id);

    /**
     * 更新字典状态
     */
    void updateDictStatus(Long id, Integer status);
}