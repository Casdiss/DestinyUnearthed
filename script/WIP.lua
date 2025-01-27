--Sustainium Crude Ore Refining
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.tdfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ROCK) and c:IsAbleToDeck()
end
function s.thfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TUNER) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_REMOVED,0,3,nil)
		and Duel.IsExistingTarget(s.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK))
	local g1=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_REMOVED,0,3,3,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g2=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_REMOVED,0,1,1,g1)
	e:SetLabelObject(g2)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,#g1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g2,#g2,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetLabelObject()
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if c or not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=3 then return end
	Duel.SendtoDeck(tg,nil,0,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	if g:IsExists(s.sfilter,1,nil,tp) then Duel.ShuffleDeck(tp) end
	if g:IsExists(s.sfilter,1,nil,1-tp) then Duel.ShuffleDeck(1-tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==3 then
		Duel.BreakEffect()
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end