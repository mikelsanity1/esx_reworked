const ESXR = new Vue({
    el: '#hud',
    render: hud => hud({
        template: '#hud_template',
        name: 'ESXR',
        components: {},
        data() {
            return {
                show: false,
                job: {
                    name: 'Unemployed',
                    grade: 'Unemployed'
                },
                job2: {
                    name: 'Unemployed',
                    grade: 'Unemployed'
                },
                status: {
                    health: 0,
                    armor: 0,
                    hunger: 0,
                    thirst: 0
                },
                listener: null,
                translations: {
                    health: 'Unknown',
                    armor: 'Unknown',
                    hunger: 'Unknown',
                    thirst: 'Unknown'
                }
            }
        },
        destroyed() {
            if (typeof this.listener !== 'undefined' && this.listener !== null) {
                window.removeEventListener('message', this.listener);
            }
        },
        mounted() {
            const self = this;

            self.listener = (event) => {
                const data = event.data || event.detail || null;

                if (typeof data == 'undefined' || data == null || !data || !data.action) { return; }

                if (self[data.action]) {
                    self[data.action](data);
                }
            };

            window.addEventListener('message', self.listener);

            self.POST('https://esx_reworked/loaded', {});
            self.GET('https://cfx-nui-esx_reworked/config/shared_config.lua', function(response) {
                let language = 'en';

                response = response || '';

                const defaultLanguage = /(?<=Configuration.DefaultLanguage = ')(.*)(?=')/gm
                const languages = response.match(defaultLanguage);

                if (languages.length > 0) {
                    language = languages[0].toLowerCase();
                } else {
                    language = 'en';
                }

                self.GET(`https://cfx-nui-esx_reworked/locales/${language}.json`, function(response) {
                    response = response || '[]';

                    const data = JSON.parse(response) || [];

                    if (data['status_health'] !== undefined) { self.translations.health = data['status_health']; }
                    if (data['status_armor'] !== undefined) { self.translations.armor = data['status_armor']; }
                    if (data['status_hunger'] !== undefined) { self.translations.hunger = data['status_hunger']; }
                    if (data['status_thirst'] !== undefined) { self.translations.thirst = data['status_thirst']; }
                });
            });
        },
        watch: {
            show() {},
            job: {
                deep: true,
                handler() { }
            },
            job2: {
                deep: true,
                handler() { }
            },
            status: {
                deep: true,
                handler() { }
            },
            translations: {
                deep: true,
                handler() { }
            }
        },
        updated() { },
        computed() { },
        methods: {
            LOADED({ job_label, job_grade, job2_label, job2_grade }) {
                this.job.name = job_label;
                this.job.grade = job_grade;
                this.job2.name = job2_label;
                this.job2.grade = job2_grade;
                this.show = true;
            },
            UPDATE_STATS({ key, value }) {
                if (this.status[key] !== undefined) {
                    this.status[key] = value
                }
            },
            UPDATE_JOB({ label, grade }) {
                this.job.name = label;
                this.job.grade = grade;
            },
            UPDATE_JOB2({ label, grade }) {
                this.job2.name = label;
                this.job2.grade = grade;
            },
            HIDE_SHOW({ status }) {
                if (status) {
                    this.show = true;
                } else {
                    this.show = false;
                }
            },
            POST: function(url, data) {
                var request = new XMLHttpRequest();
    
                request.open('POST', url, true);
                request.setRequestHeader('Content-Type', 'application/json; charset=UTF-8');
                request.send(JSON.stringify(data));
            },
            GET: function(url, callback, type) {
                type = type || 'text';

                var request = new XMLHttpRequest();

                request.open('GET', url, true);
                request.responseText = type;
                request.onload = function() {
                    if (request.status === 200) {
                        callback(request.response);
                    }
                }
                request.send();
            }
        }
    })
});