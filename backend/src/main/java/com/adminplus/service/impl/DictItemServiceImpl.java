package com.adminplus.service.impl;

import com.adminplus.dto.DictItemCreateReq;
import com.adminplus.dto.DictItemUpdateReq;
import com.adminplus.entity.DictEntity;
import com.adminplus.entity.DictItemEntity;
import com.adminplus.exception.BizException;
import com.adminplus.repository.DictItemRepository;
import com.adminplus.repository.DictRepository;
import com.adminplus.service.DictItemService;
import com.adminplus.vo.DictItemVO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 字典项服务实现
 *
 * @author AdminPlus
 * @since 2026-02-06
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class DictItemServiceImpl implements DictItemService {

    private final DictItemRepository dictItemRepository;
    private final DictRepository dictRepository;

    @Override
    @Transactional(readOnly = true)
    @Cacheable(value = "dictItem", key = "'dictId:' + #dictId")
    public List<DictItemVO> getDictItemsByDictId(Long dictId) {
        return dictItemRepository.findByDictIdOrderBySortOrderAsc(dictId).stream()
                .map(this::toVO)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    @Cacheable(value = "dictItem", key = "'type:' + #dictType")
    public List<DictItemVO> getDictItemsByType(String dictType) {
        DictEntity dict = dictRepository.findByDictType(dictType)
                .orElseThrow(() -> new BizException("字典不存在"));

        return dictItemRepository.findByDictIdAndStatusOrderBySortOrderAsc(dict.getId(), 1).stream()
                .map(item -> toVOWithDictType(item, dict.getDictType()))
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    @Cacheable(value = "dictItem", key = "'id:' + #id")
    public DictItemVO getDictItemById(Long id) {
        DictItemEntity item = dictItemRepository.findById(id)
                .orElseThrow(() -> new BizException("字典项不存在"));

        DictEntity dict = dictRepository.findById(item.getDictId())
                .orElseThrow(() -> new BizException("字典不存在"));

        return toVOWithDictType(item, dict.getDictType());
    }

    @Override
    @Transactional
    @CacheEvict(value = "dictItem", allEntries = true)
    public DictItemVO createDictItem(DictItemCreateReq req) {
        DictEntity dict = dictRepository.findById(req.dictId())
                .orElseThrow(() -> new BizException("字典不存在"));

        DictItemEntity item = new DictItemEntity();
        item.setDictId(req.dictId());
        item.setLabel(req.label());
        item.setValue(req.value());
        item.setSortOrder(req.sortOrder() != null ? req.sortOrder() : 0);
        item.setStatus(req.status() != null ? req.status() : 1);
        item.setRemark(req.remark());

        item = dictItemRepository.save(item);
        log.info("创建字典项成功: {} - {}", dict.getDictType(), item.getLabel());
        return toVOWithDictType(item, dict.getDictType());
    }

    @Override
    @Transactional
    @CacheEvict(value = "dictItem", allEntries = true)
    public DictItemVO updateDictItem(Long id, DictItemUpdateReq req) {
        DictItemEntity item = dictItemRepository.findById(id)
                .orElseThrow(() -> new BizException("字典项不存在"));

        DictEntity dict = dictRepository.findById(item.getDictId())
                .orElseThrow(() -> new BizException("字典不存在"));

        item.setLabel(req.label());
        item.setValue(req.value());
        item.setSortOrder(req.sortOrder() != null ? req.sortOrder() : item.getSortOrder());
        item.setStatus(req.status() != null ? req.status() : item.getStatus());
        item.setRemark(req.remark());

        item = dictItemRepository.save(item);
        log.info("更新字典项成功: {} - {}", dict.getDictType(), item.getLabel());
        return toVOWithDictType(item, dict.getDictType());
    }

    @Override
    @Transactional
    @CacheEvict(value = "dictItem", allEntries = true)
    public void deleteDictItem(Long id) {
        DictItemEntity item = dictItemRepository.findById(id)
                .orElseThrow(() -> new BizException("字典项不存在"));

        dictItemRepository.delete(item);
        log.info("删除字典项成功: {}", item.getLabel());
    }

    @Override
    @Transactional
    @CacheEvict(value = "dictItem", allEntries = true)
    public void updateDictItemStatus(Long id, Integer status) {
        DictItemEntity item = dictItemRepository.findById(id)
                .orElseThrow(() -> new BizException("字典项不存在"));

        item.setStatus(status);
        dictItemRepository.save(item);
        log.info("更新字典项状态成功: {}", item.getLabel());
    }

    private DictItemVO toVO(DictItemEntity item) {
        return new DictItemVO(
                item.getId(),
                item.getDictId(),
                null,
                item.getLabel(),
                item.getValue(),
                item.getSortOrder(),
                item.getStatus(),
                item.getRemark(),
                item.getCreateTime(),
                item.getUpdateTime()
        );
    }

    private DictItemVO toVOWithDictType(DictItemEntity item, String dictType) {
        return new DictItemVO(
                item.getId(),
                item.getDictId(),
                dictType,
                item.getLabel(),
                item.getValue(),
                item.getSortOrder(),
                item.getStatus(),
                item.getRemark(),
                item.getCreateTime(),
                item.getUpdateTime()
        );
    }
}