--@SuperType luaIde#cc.Layer
local GameNote =
    class(
    "GameNote",
    function(...)
        return display.newLayer()
    end
)

local contentSizeHeight = 0

local Item =
    class(
    "Item",
    function(param)
        -- dump(param)
        local itemData = param.itemData

        local proxy = CCBProxy:create()
        local rootnode = {}

        local node = CCBReaderLoad("ccbi/gamenote/noteItem.ccbi", proxy, rootnode)
        local textNode = rootnode["text_node"]
        -- dump(itemData.tcolor)

        local title_color =
            cc.c3b(
            checkint(string.format("%s", "0x" .. string.sub(itemData.tcolor, 1, 2))),
            checkint(string.format("%s", "0x" .. string.sub(itemData.tcolor, 3, 4))),
            checkint(string.format("%s", "0x" .. string.sub(itemData.tcolor, 5, 6)))
        )

        local content_color =
            cc.c3b(
            checkint(string.format("%s", "0x" .. string.sub(itemData.ccolor, 1, 2))),
            checkint(string.format("%s", "0x" .. string.sub(itemData.ccolor, 3, 4))),
            checkint(string.format("%s", "0x" .. string.sub(itemData.ccolor, 5, 6)))
        )

        local titleLabel
        if itemData.teffect == 1 then
            titleLabel =
                newTTFLabelWithOutline(
                {
                    text = itemData.title,
                    font = FONTS_NAME.font_haibao,
                    color = title_color,
                    outlineColor = FONT_COLOR.NOTE_TITLE_OUTLINE,
                    size = checkint(itemData.tfont),
                    align = cc.TEXT_ALIGNMENT_CENTER
                }
            )
        else
            titleLabel =
                newTTFLabelWithOutline(
                {
                    text = itemData.title,
                    font = FONTS_NAME.font_haibao,
                    color = title_color,
                    size = checkint(itemData.tfont),
                    align = cc.TEXT_ALIGNMENT_CENTER
                }
            )
        end

        titleLabel:setPosition(node:getContentSize().width / 2, node:getContentSize().height / 2)
        node:addChild(titleLabel)

        local viewSize = cc.size(textNode:getContentSize().width, 0)

        -- dump(itemData.content)
        -- dump(json.encode(itemData.content))

        local txt = string.gsub(itemData.content, "\r\n", "\n")

        local contentLabel =
            newTTFLabel(
            {
                text = txt,
                font = FONTS_NAME.font_fzcy,
                color = content_color,
                size = checkint(itemData.cfont),
                align = cc.TEXT_ALIGNMENT_LEFT,
                valign = cc.VERTICAL_TEXT_ALIGNMENT_TOP,
                dimensions = viewSize
            }
        )

        contentLabel:setAnchorPoint(0.5, 1)
        contentLabel:setPosition(node:getContentSize().width / 2, 0)
        node:addChild(contentLabel)

        contentSizeHeight = contentLabel:getContentSize().height
        -- dump(contentSizeHeight)

        return node
    end
)

function GameNote:ctor()
    self:enableNodeEvents()
    -- 半透背景
    --@RefType luaIde#cc.LayerColor
    local bg = display.newLayer(cc.c4b(0, 0, 0, 100))
    bg:setScale(display.height / bg:getContentSize().height)
    self:addChild(bg)

    setTouchEnabled(bg, true)

    local proxy = CCBProxy:create()
    -- local ccbReader = proxy:createCCBReader()
    local rootnode = rootnode or {}

    -- 背景卷轴
    local ccb_mm_name = "ccbi/gamenote/gamenote.ccbi"
    local node = CCBReaderLoad(ccb_mm_name, proxy, rootnode)
    self.layer = tolua.cast(node, "cc.Layer")
    self.layer:setPosition(display.width / 2, display.height / 2)
    self:addChild(self.layer)

    -- 进入游戏按钮
    local okBtn = rootnode["btn_ok"]
    okBtn:registerControlEventHandler(
        function(sender)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))

            sender:runAction(
                transition.sequence(
                    {
                        cc.ScaleTo:create(0.08, 0.8),
                        cc.ScaleTo:create(0.1, 1.2),
                        cc.ScaleTo:create(0.02, 1),
                        cc.CallFunc:create(
                            function()
                                self:removeSelf()
                            end
                        )
                    }
                )
            )
        end,
        CCControlEventTouchDown
    )

    local height = 0
    local contentViewSize = rootnode["contentView"]:getContentSize()

    for i, v in ipairs(game.player.m_gamenote) do
        local item =
            Item.new(
            {
                itemData = v
            }
        )

        item:setPosition(contentViewSize.width / 2, -height)
        rootnode["contentView"]:addChild(item)

        height = height + item:getContentSize().height + contentSizeHeight + 10
    end

    local sz = cc.size(contentViewSize.width, contentViewSize.height + height)

    rootnode["descView"]:setContentSize(sz)
    rootnode["contentView"]:setPosition(cc.p(sz.width / 2, sz.height))

    local scrollView = rootnode["scrollView"]
    scrollView:updateInset()
    scrollView:setContentOffset(cc.p(0, -sz.height + scrollView:getViewSize().height), false)
end

function GameNote:onExit(...)
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
end

return GameNote
