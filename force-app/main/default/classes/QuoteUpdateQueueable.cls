public class QuoteUpdateQueueable implements Queueable {
    private List<Quote> quotesToUpdate;

    public QuoteUpdateQueueable(List<Quote> quotesToUpdate) {
        this.quotesToUpdate = quotesToUpdate;
    }

    public void execute(QueueableContext context) {
        update quotesToUpdate;
    }
}