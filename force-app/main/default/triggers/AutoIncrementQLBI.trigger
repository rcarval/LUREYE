trigger AutoIncrementQLBI on QuoteLineItem (before insert) {
    Map<Id, Integer> quoteItemCount = new Map<Id, Integer>();
    // Primero, contamos el número de ítems que se van a insertar por cada cotización
    for (QuoteLineItem qli : Trigger.new) {
        if (quoteItemCount.containsKey(qli.QuoteId)) {
            quoteItemCount.put(qli.QuoteId, quoteItemCount.get(qli.QuoteId) + 1);
        } else {
            quoteItemCount.put(qli.QuoteId, 1);
        }
    }

    // Luego, obtenemos el máximo número actual por cotización
    Map<Id, Decimal> maxNumberPerQuote = new Map<Id, Decimal>();
    for (AggregateResult ar : [
        SELECT QuoteId, MAX(QLBI__c) maxQLBI 
        FROM QuoteLineItem 
        WHERE QuoteId IN :quoteItemCount.keySet() 
        GROUP BY QuoteId
    ]) {
        maxNumberPerQuote.put((Id)ar.get('QuoteId'), (Decimal)ar.get('maxQLBI'));
    }

    // Asignamos el número siguiente en secuencia a los nuevos ítems
    for (QuoteLineItem qli : Trigger.new) {
        Decimal maxNumber = maxNumberPerQuote.containsKey(qli.QuoteId) ? maxNumberPerQuote.get(qli.QuoteId) : 0;
        qli.QLBI__c = maxNumber + 1;
        // Aumentamos el número máximo para el próximo ítem de la misma cotización en este trigger
        maxNumberPerQuote.put(qli.QuoteId, qli.QLBI__c);
    }
}