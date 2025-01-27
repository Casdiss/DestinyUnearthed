--Sustainium Crude Ore Refining
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Return 3 banished Rock monsters to the deck and 1 banished Tuner to your hand.
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(aux.selfbanishcost)
	e2:SetTarget(s.gytarget)
	e2:SetOperation(s.gyactivate)
	c:RegisterEffect(e2)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.bnfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	if chk==0 then return #g>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local rg=g:Select(tp,1,3,nil)
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
	e:SetLabel(#rg)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ac=e:GetLabel()
	Duel.ConfirmDecktop(tp,ac)
	local g=Duel.GetDecktopGroup(tp,ac)
	if #g>0 and g:IsExists(s.exfilter,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:FilterSelect(tp,s.exfilter,1,1,nil)
		Duel.DisableShuffleCheck()
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
		Duel.ShuffleHand(tp)
		ac=ac-1
	end
	if ac>0 then
		Duel.MoveToDeckTop(g,tp)
		Duel.SortDecktop(tp,tp,ac)
	end
end
function s.bnfilter(c)
	return c:IsRace(RACE_ROCK) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true,false)
end
function s.exfilter(c)
	return c:IsSetCard(0x999) and c:IsMonster() and c:IsAbleToHand()
end
function s.tgfilter(c)
	local th=(c:IsRace(RACE_ROCK) and c:IsAbleToDeck())
	local td=(c:IsType(TYPE_TUNER) and c:IsAbleToHand())
	return c:IsFaceup() and (th or td)
end
function s.sfilter(c,tp)
	return c:IsLocation(LOCATION_DECK) and c:IsControler(tp)
end
function s.tnfilter(c,tp)
	return c:IsType(TYPE_TUNER)
end
function s.tgcon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsRace,nil,RACE_ROCK)>2 and sg:FilterCount(Card.IsType,nil,TYPE_TUNER)>0
end
function s.gytarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local tg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_REMOVED,0,nil,e)
	if chk==0 then return #tg>3 and aux.SelectUnselectGroup(tg,e,tp,4,4,s.tgcon,0) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local g1=aux.SelectUnselectGroup(tg,e,tp,4,4,s.tgcon,1,tp,HINTMSG_TODECK)
	local tn=g1:Filter(s.tnfilter,nil)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local g2=tn:SelectUnselect(Group.CreateGroup,tp,false,false,1,1)
	e:SetLabelObject(g2)
	Duel.SetTargetCard(g1+g2)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,#g1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g2,1,0,0)
end
function s.gyactivate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetLabelObject()
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local dg=tg:Filter(aux.TRUE,c)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,c,e)~=3 then return end
	Duel.SendtoDeck(dg,nil,0,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	if g:IsExists(s.sfilter,1,nil,tp) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==3 and c:IsLocation(LOCATION_REMOVED) then
		Duel.BreakEffect()
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end