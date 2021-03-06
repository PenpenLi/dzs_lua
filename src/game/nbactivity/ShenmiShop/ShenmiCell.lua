local ShenmiCell =
    class(
    ShenmiCell,
    function()
        return CCTableViewCell:new()
    end
)

function ShenmiCell:getContentSize()
    if self.Cntsize ~= nil then
    else
        local proxy = CCBProxy:create()
        local rootnode = {}
        local node = CCBReaderLoad("nbhuodong/shenmi_duihuan_item.ccbi", proxy, rootnode)
        self.Cntsize = rootnode["itemBg"]:getContentSize()
    end

    return self.Cntsize
end

function ShenmiCell:create(param)
    local viewSize = param.viewSize
    local informationFunc = param.informationFunc
    self._exchangeFunc = param.exchangeFunc
    local proxy = CCBProxy:create()
    self._rootnode = {}

    -- dump(viewSize.width)

    local node = CCBReaderLoad("nbhuodong/shenmi_duihuan_item.ccbi", proxy, self._rootnode)
    node:setPosition(viewSize.width * 0.5, self._rootnode["itemBg"]:getContentSize().height * 0.5)
    self:addChild(node)

    self:updateItem(param.itemData)

    self._rootnode["exchangeBtn"]:registerControlEventHandler(
        function()
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
            if self._exchangeFunc ~= nil then
                self:updateExchangeBtn(false)
                self._exchangeFunc(self)
            end
        end,
        CCControlEventTouchUpInside
    )

    local rewardIcon = self._rootnode["itemIcon"]
    self:setIconTouchEnabled(true)
    addNodeEventListener(
        rewardIcon,
        cc.Handler.EVENT_TOUCH_BEGAN,
        function()
            self:setIconTouchEnabled(false)
            return true
        end
    )
    addNodeEventListener(
        rewardIcon,
        cc.Handler.EVENT_TOUCH_ENDED,
        function()
            informationFunc(self)
        end
    )

    return self
end

function ShenmiCell:setIconTouchEnabled(bEnabled)
    setTouchEnabled(self._rootnode["itemIcon"], bEnabled)
end

function ShenmiCell:updateExchangeBtn(bEnabled)
    self._rootnode["exchangeBtn"]:setEnabled(bEnabled)
end

function ShenmiCell:updateExchangeNum(num)
    self._itemData.limitNum = num or self._itemData.limitNum

    -- 可兑换次数
    self._rootnode["exchange_num"]:setString("兑换次数：" .. self._itemData.limitNum)

    -- 更新按钮状态
    if self._itemData.limitNum == 0 then
        self:updateExchangeBtn(false)
    else
        self:updateExchangeBtn(true)
    end
end

function ShenmiCell:updateItem(itemData)
    self._itemData = itemData
    self:updateExchangeNum(self._itemData.limitNum)

    -- 图标
    local rewardIcon = self._rootnode["itemIcon"]
    rewardIcon:removeAllChildren(true)
    ResMgr.refreshIcon(
        {
            id = self._itemData.id,
            resType = self._itemData.iconType,
            itemBg = rewardIcon,
            iconNum = self._itemData.num,
            isShowIconNum = false,
            numLblSize = 22,
            numLblColor = cc.c3b(0, 255, 0),
            numLblOutColor = cc.c3b(0, 0, 0)
        }
    )

    -- 属性图标
    local canhunIcon = self._rootnode["reward_canhun"]
    local suipianIcon = self._rootnode["reward_suipian"]
    canhunIcon:setVisible(false)
    suipianIcon:setVisible(false)

    if self._itemData.type == 3 then
        -- 装备碎片
        suipianIcon:setVisible(true)
    elseif self._itemData.type == 5 then
        -- 残魂(武将碎片)
        canhunIcon:setVisible(true)
    end

    -- 名称
    local nameColor = cc.c3b(255, 255, 255)
    if self._itemData.iconType == ResMgr.ITEM or self._itemData.iconType == ResMgr.EQUIP then
        nameColor = ResMgr.getItemNameColor(self._itemData.id)
    elseif self._itemData.iconType == ResMgr.HERO then
        nameColor = ResMgr.getHeroNameColor(self._itemData.id)
    end

    local nameLbl =
        newTTFLabelWithShadow(
        {
            text = self._itemData.name,
            size = 22,
            color = nameColor,
            shadowColor = cc.c3b(0, 0, 0),
            font = FONTS_NAME.font_haibao,
            align = cc.TEXT_ALIGNMENT_CENTER
        }
    )

    nameLbl:setPosition(nameLbl:getContentSize().width / 2, -nameLbl:getContentSize().height / 2)
    self._rootnode["name_lbl"]:removeAllChildren()
    self._rootnode["name_lbl"]:addChild(nameLbl)

    -- 消耗类型
    if self._itemData.moneyType == 1 then
        self._rootnode["cost_name"]:setString("元宝：")
    elseif self._itemData.moneyType == 2 then
        self._rootnode["cost_name"]:setString("银币：")
    elseif self._itemData.moneyType == 10 then
        self._rootnode["cost_name"]:setString("魂玉：")
    end

    -- 图标
    ResMgr.refreshMoneyIcon({itemBg = self._rootnode["cost_icon"], moneyType = self._itemData.moneyType})

    -- 价格
    self._rootnode["cost_num"]:setString(tostring(self._itemData.price))
end

function ShenmiCell:refresh(itemData)
    self:updateItem(itemData)
end

return ShenmiCell
