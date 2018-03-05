<?php
/**
 * This script queries Jira and provides monthly snippets results
 *
 * Usage: jira-tool.php startDate=2017-03-20 endDate=2017-04-17 devs=spider.man,super.man
 */

ini_set('memory_limit', '1024M');
date_default_timezone_set('Europe/London');

$job = new StatsSnippetsPrinterJob();
$job->run($argv);
die;

class StatsSnippetsPrinterJob {

	public function run($argv) {
		list($ticket, $user, $password) = $this->parseScriptArgs($argv);
		$jiraClient = new JiraCurlClient($user, $password);
		$issue = $jiraClient->getIssue($ticket);
		$title = $issue->getSummary();
		$qa_time = $issue->getQaEstimations();
		$status = $issue->getTaskStatus();

		// if (empty($qa_time)) {
		// 	$qa_time = "QA (est.) N/A";
		// } else {
		// 	$qa_time = "QA (est.) " . $qa_time;
		// }

		$data = [
			"status" => $status,
			"title" => $title,
			"qa_est" => $qa_time
		];

		header('Content-Type: application/json');
		fwrite(STDOUT, json_encode($data));

		// echo json_encode($data);

		// return directly
		// $output = "[$status]|$title|$qa_time";
		// fwrite(STDOUT, $output);
	}

	/**
	 * @param string[] $args
	 * @return mixed[] array(string $ticket)
	 */
	public function parseScriptArgs($args) {
		$parsedArgs = array();

		foreach($args as $arg) {
			list($argName, $argValue) = explode('=', $arg);
			$parsedArgs[$argName] = $argValue;
		}

		if (!isset($parsedArgs['ticket']) || empty($parsedArgs['ticket'])) {
			$this->usage(); die;
		}

		if (!isset($parsedArgs['u']) || empty($parsedArgs['u'])) {
			$this->usage(); die;
		}

		if (!isset($parsedArgs['p']) || empty($parsedArgs['p'])) {
			$this->usage(); die;
		}

		return array(
			$parsedArgs['ticket'],
			$parsedArgs['u'],
			$parsedArgs['p']
		);
	}

	public function usage() {
		echo "Usage:\n";
		echo "$~ php jira-tool.php ticket=MOX-12345 u=jira_user p=test1234\n";
	}
}

class JiraCurlClient {
	const BASE_ISSUE_URL = 'https://jira.badoojira.com/rest/api/latest/issue/';
	function __construct($user, $password) {
			$this->user = $user;
			$this->password = $password;
	}

	public function getIssue($ticket) {
		$path = self::BASE_ISSUE_URL . $ticket;
		$jiraResponseJson = $this->requestJiraJql($path);
		$record = json_decode($jiraResponseJson, true);
		return new Issue($record);
	}

	/**
	 * @param string $jql Jira Query
	 * @param int $maxResults
	 * @param bool $expandAll
	 * @return array
	 */
	private function requestJiraJql($url) {
		$ch = curl_init();
		curl_setopt($ch, CURLOPT_URL, $url);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
		curl_setopt($ch, CURLOPT_FAILONERROR, 1);
		curl_setopt($ch, CURLOPT_HEADER, 0);
		curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 30);
		curl_setopt($ch, CURLOPT_MAXREDIRS, 2);
		curl_setopt($ch, CURLOPT_FOLLOWLOCATION, 1);
		curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
		curl_setopt($ch, CURLOPT_USERPWD, $this->user . ':' . $this->password);
		$response = curl_exec($ch);
		curl_close($ch);
		return $response;
	}

}

class StoryPointSizes {
	const UNKNOWN = 'UNKNOWN';
	const XXS = 'XXS';
	const XS  = 'XS';
	const S   = 'S';
	const M   = 'M';
	const L   = 'L';
	const XL  = 'XL';
	const XXL = 'XXL';

	private static $sizes = array(
		self::UNKNOWN  => 0.1,
		self::XXS => 0.5,
		self::XS  => 1.0,
		self::S   => 2.0,
		self::M   => 3.0,
		self::L   => 5.0,
		self::XL  => 8.0,
		self::XXL => 13.0,
	);

	public static function getSizesSortedDesc() {
		$sizes = self::$sizes;
		arsort($sizes);
		return $sizes;
	}

	public static function getSizeForStoryPoints($storyPoints) {
		// If not set, return XS
		if (!$storyPoints) {
			return self::UNKNOWN;
		}

		// Approximate the size
		$storyPoints = (float) $storyPoints;
		$sizes = self::getSizesSortedDesc();
		$result = self::XXL;
		foreach ($sizes as $sizeName => $sizeValue) {
			if ($storyPoints <= $sizeValue) {
				$result = $sizeName;
			} else {
				return $result;
			}
		}

		return $result;
	}
}

class Issue {
	const TYPE_BUG = 'Bug';
	const TYPE_FEATURE = 'New Feature';
	const TYPE_TASK = 'Task';

	public function __construct($rawJiraIssue) {
		$this->record = $rawJiraIssue;
	}

	/**
	 * @return string the usual jira developer name for queries
	 */
	public function getDeveloper() {
		return $this->record['fields']['customfield_10463']['name'];
	}

	/**
	 * @return string only used for changes of state. Key can defer from developer name
	 */
	public function getDeveloperKey() {
		return $this->record['fields']['customfield_10463']['key'];
	}

	/**
	 * @return string
	 */
	public function getKey() {
		return $this->record['key'];
	}

	/**
	 * @return string
	 */
	public function getType() {
		return $this->record['fields']['issuetype']['name'];
	}

	/**
	 * @return string
	 */
	public function getSummary() {
		return $this->record['fields']['summary'];
	}

	/**
	 * @return string
	 */
	public function getStoryPoints() {
		return (string)$this->record['fields']['customfield_10033'];
	}

	/**
	 * @return string, one of StoryPointSizes::*
	 */
	public function getSize() {
		return StoryPointSizes::getSizeForStoryPoints($this->getStoryPoints());
	}

	/**
	 * @return int
	 */
	public function getQaEstimations() {
		return $this->record['fields']['customfield_15466'];
	}

	/**
	 * @return bool
	 */
	public function isNoQa() {
		return $this->record['fields']['customfield_10663']['value'] == 'NO';
	}

	/**
	 * @return string
	 */
	public function getTaskStatus() {
		return (string)$this->record['fields']['status']['name'];
	}

	/**
	 * @param bool $includeSize size of the issue
	 * @return string
	 */
	public function getAsString($includeSize = true) {
		$str = '';
		if ($includeSize) {
			$str .= "[{$this->getSize()}] ";
		}
		return $str .  "{$this->getKey()} - {$this->getSummary()}";
	}

	/**
	 * @param DateTime $fromDateTime
	 * @param DateTime $toDateTime
	 * @return array containing reviewers per each review as:
	 *               [int reviewIndex => array [string reviewerName, ... ], ...]
	 */
	public function getReviews(DateTime $fromDateTime = null, DateTime $toDateTime = null) {
		$reviews = array();
		$partialReviewers = array();
		$reviewIndex = 0;
		$inReview = false;

		$histories = $this->record['changelog']['histories'];
		foreach ($histories as $history) {
			$historyChange = new HistoryChange($history);
			if ($historyChange->dateTime < $fromDateTime || $historyChange->dateTime > $toDateTime) {
				continue;
			}

			if ($historyChange->isStatusChange) {
				if ($historyChange->statusFrom == 'In Progress' && $historyChange->statusTo === 'On Review') {
					$inReview = true;
				}
				if ($historyChange->statusFrom == 'On Review' && $historyChange->statusTo !== 'On Review') {
					$inReview = false;
					$partialReviewers[] = DevelopersKeyCache::getDeveloperFromKey($historyChange->assigneeFrom);
					$partialReviewers = array_unique($partialReviewers);
					$partialReviewers = array_filter($partialReviewers);
					if (!empty($partialReviewers)) {
						$reviews[$reviewIndex] = $partialReviewers;
						$partialReviewers = array();
						$reviewIndex++;
					}
				}
			} elseif ($inReview && $historyChange->isAssigneeChange) {
				$partialReviewers[] = DevelopersKeyCache::getDeveloperFromKey($historyChange->assigneeTo);
			}
		}
		return $reviews;
	}

	/**
	 * @return array (string developer => DateTime[])
	 */
	public function getCommitsDateTimesByDeveloper($fromDateTime, $toDateTime) {
		$dateTimes = array();
		$comments = $this->record['fields']['comment']['comments'];
		foreach ($comments as $comment) {
			if ($comment['author']['name'] == 'aida' && strstr($comment['body'], '=commitdiff&')) {

				preg_match("/^\|([^|]+)\|/", $comment['body'], $matches);
				$developer = isset($matches[1]) ? $matches[1] : null;
				$time = new DateTime($comment['created']);
				$time->modify('+1 hours');
				if ($time > $fromDateTime && $time < $toDateTime && $developer) {
					$dateTimes[$developer][] = $time;
				}
			}
		}
		return $dateTimes;
	}
}
