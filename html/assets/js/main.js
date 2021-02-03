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
                    health: 100,
                    armor: 100,
                    hunger: 100,
                    thirst: 100
                },
                listener: null
            }
        },
        destroyed() {
            if (typeof this.listener !== 'undefined' && this.listener !== null) {
                window.removeEventListener('message', this.listener);
            }
        },
        mounted() {
            this.listener = (event) => {
                const data = event.data || event.detail || null;

                if (typeof data == 'undefined' || data == null || !data || !data.action) { return; }

                if (this[data.action]) {
                    this[data.action](data);
                }
            };

            window.addEventListener('message', this.listener);

            this.POST('https://esx_reworked/loaded', {});
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
                if (this.status[key]) {
                    this.status[key] = Math.round(value)
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
            }
        }
    })
});