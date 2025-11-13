public class CS_QuoteUpdateQueueable implements Queueable {
    private List<Quote> quotesToUpdate;

    public CS_QuoteUpdateQueueable(List<Quote> quotesToUpdate) {
        this.quotesToUpdate = quotesToUpdate;
    }

    public void execute(QueueableContext context) {
        update quotesToUpdate;
    }
}