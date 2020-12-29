from html.parser import HTMLParser


class ReportParser(HTMLParser):
    def __init__(self):
        HTMLParser.__init__(self)
        self.counter = {}
        self.result = []
        self.tbl_index_h = {}
        self.tbl_index_v = {}
        self.tbl_td = []
        self.tbl_tda = {}
        self.tbl_tr = {}
        self.tags = []

    def handle_starttag(self, tag, attrs):
        self.counter[tag] = self.counter.get(tag, 0) + 1
        self.tags.append(tag)
        if tag == "td":
            for k, v in attrs:
                if k == "title":
                    # Read param values.
                    self.tbl_tda[k] = v.split("; ") if ";" in v else v
                # if attr == 'title':

    def handle_endtag(self, tag):
        # Removes ended tags from the list.
        tindex = list(reversed(self.tags)).index(tag) - 1
        del self.tags[-tindex:]
        # Resets td/tr counter at the end of the table.
        if tag == "table":
            if self.counter.get("td", 0) > 0:
                del self.counter["td"]
            if self.counter.get("tr", 0) > 0:
                del self.counter["tr"]
            self.tbl_index_h = {}
            self.tbl_index_v = {}
        if tag == "tr":
            if self.counter.get("td", 0) > 0:
                # End of row.
                del self.counter["td"]
                if self.counter["tr"] > 1:
                    data = {"row": self.tbl_td, **self.tbl_tda}
                    self.tbl_tr[self.counter["tr"]] = data
                self.tbl_td = []

    def handle_data(self, data):
        if len(self.tags) > 0:
            if self.tags[-1] == "td":
                if self.counter["td"] == 1:
                    # Saves table's vertical index names.
                    self.tbl_index_v[data] = self.counter["tr"]
                if self.counter["tr"] == 1:
                    # Saves table's horizontal index names.
                    self.tbl_index_h[data] = self.counter["td"]
                else:
                    self.tbl_td.append(data)
                    print("TD: ", self.tbl_td)

                try:
                    # value = float(data)
                    pass
                except ValueError:
                    # Value is not numeric.
                    pass
                else:
                    # Value is numeric.
                    pass

    def sort_by(self, key):
        pass
