--Sustainium Ore Node
--flavor-text = '''A peculiar mineral that seems to defy the laws of thermodynamics. It can burn endlessly and tools made from it never wear down. Prized above all else, the might of empires is measured in its weight.'''
local s,id=GetID()
function s.initial_effect(c)
	--Return 1 Rock monster to the top of the deck
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCondition(s.synccon)
	e1:SetOperation(s.chop)
	c:RegisterEffect(e1)
	--Excavate 1 cards, add 1 "Sustainium" monster to the hand
	local e2=e1:Clone()
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(s.dtchcon)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3)
end
function s.synccon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO
end
function s.dtchcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_XYZ)
			and c:IsPreviousLocation(LOCATION_OVERLAY)
end
function s.exfilter(c)
	return c:IsSetCard(0x999) and c:IsAbleToHand()
end
function s.tdfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ROCK) and c:IsAbleToDeck()
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.HintSelection(Group.FromCards(c))
	local g1=Duel.GetDecktopGroup(tp,1)
	local g2=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_REMOVED,0,nil)
	local select=2
	if #g1>0 and #g2>0 then
		select=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))
	elseif #g1>0 then
		select=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,2))
		if select==1 then select=2 end
	elseif #g2>0 then
		select=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))+1
	else
		select=Duel.SelectOption(tp,aux.Stringid(id,2))
		select=2
	end
	if select==0 then
		local ac=1
		Duel.ConfirmDecktop(tp,ac)
		if #g1>0 and g1:IsExists(s.exfilter,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			Duel.DisableShuffleCheck()
			Duel.SendtoHand(g1,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g1)
			Duel.ShuffleHand(tp)
		end
	elseif select==1 then
		if #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local sg=g2:Select(tp,1,1,nil)
			Duel.HintSelection(sg)
			Duel.SendtoDeck(sg,nil,0,REASON_EFFECT+REASON_RETURN)
		end
	else
	end
end