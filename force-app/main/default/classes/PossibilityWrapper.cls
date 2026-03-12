public with sharing class PossibilityWrapper {
    public Integer minQuestions;
    public Integer maxQuestions;
    public Integer total;
    public List<PathWrapper> paths;

    // Constructor
    public PossibilityWrapper() {
        this.minQuestions = 0;
        this.maxQuestions = 0;
        this.total = 0;
        this.paths = new List<PathWrapper>();
    }

    public class PathWrapper {
        public Integer count = 0;
        public List<String> questions = new List<String>();
    }
}