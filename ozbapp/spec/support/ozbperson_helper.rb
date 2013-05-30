def getOZBPerson(pnr)
	return OZBPerson.where("mnr = ?", pnr).first
end